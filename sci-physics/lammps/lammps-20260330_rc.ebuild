# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_OPTIONAL=1
DISTUTILS_USE_PEP517=setuptools
CMAKE_MAKEFILE_GENERATOR=emake
# Doc building insists on fetching mathjax
# DOCS_BUILDER="doxygen"
# DOCS_DEPEND="
# 	media-gfx/graphviz
# 	dev-libs/mathjax
# "

inherit cmake fortran-2 distutils-r1 # docs

convert_month() {
	local months=( "" Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )
	echo ${months[${1#0}]}
}

MY_DATE="${PV:0:8}"
MY_SUFFIX="${PV:8}"

MY_YEAR="${MY_DATE:0:4}"
MY_MONTH="$(convert_month ${MY_DATE:4:2})"
MY_DAY="$((10#${MY_DATE:6:2}))"

if [[ "${MY_SUFFIX:0:3}" == "_rc" ]]; then
	MY_TYPE="patch"
	MY_SUFFIX=""
elif [[ "${MY_SUFFIX:0:2}" == "_p" ]]; then
	MY_TYPE="stable"
	MY_SUFFIX="_update${MY_SUFFIX#_p}"
else
	MY_TYPE="stable"
	MY_SUFFIX=""
fi

MY_PV="${MY_DAY}${MY_MONTH}${MY_YEAR}${MY_SUFFIX}"
MY_P="${PN}-${MY_TYPE}_${MY_PV}"

DESCRIPTION="Large-scale Atomic/Molecular Massively Parallel Simulator"
HOMEPAGE="https://www.lammps.org"
SRC_URI="
	https://github.com/lammps/lammps/archive/refs/tags/${MY_TYPE}_${MY_PV}.tar.gz
	test? (
		https://github.com/google/googletest/archive/release-1.12.1.tar.gz
			-> ${PN}-gtest-1.12.1.tar.gz
	)
	pace? (
		https://github.com/ICAMS/lammps-user-pace/archive/refs/tags/v.2023.11.25.fix2.tar.gz
			-> ${PN}-pace-v.2023.11.25.fix2.tar.gz
	)
"
S="${WORKDIR}/${MY_P}/cmake"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda examples extra gzip hip kokkos lammps-memalign mpi opencl openmp pace python test"
# Requires write access to /dev/dri/renderD...
RESTRICT="test"

RDEPEND="
	app-arch/gzip
	media-libs/libpng:0
	virtual/zlib
	mpi? (
		virtual/mpi
		sci-libs/hdf5:=[mpi]
	)
	python? ( ${PYTHON_DEPS} )
	sci-libs/voro++
	virtual/blas
	virtual/lapack
	sci-libs/fftw:3.0=
	sci-libs/netcdf:=
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4.2.9-r1:= )
	opencl? ( virtual/opencl )
	kokkos? ( >=dev-cpp/kokkos-5.0.2 )
	hip? (
		dev-util/hip:=
		sci-libs/hipCUB:=
	)
	dev-cpp/eigen:3
	"
BDEPEND="${DISTUTILS_DEPS}"
DEPEND="${RDEPEND}
	test? (
		dev-cpp/gtest
		dev-libs/libyaml
	)
"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	?? ( cuda opencl hip )
"

src_prepare() {
	cmake_src_prepare
	if use python; then
		pushd ../python || die
		distutils-r1_src_prepare
		popd || die
	fi
	if use test; then
		mkdir "${BUILD_DIR}/_deps"
		cp "${DISTDIR}/${PN}-gtest-1.12.1.tar.gz" "${BUILD_DIR}/_deps/release-1.12.1.tar.gz"
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_MPI=$(usex mpi)
		-DBUILD_DOC=OFF
		#-DBUILD_DOC=$(usex doc)
		-DENABLE_TESTING=$(usex test)
		-DPKG_ASPHERE=ON
		-DPKG_BODY=ON
		-DPKG_CLASS2=ON
		-DPKG_COLLOID=ON
		-DPKG_COMPRESS=ON
		-DPKG_CORESHELL=ON
		-DPKG_DIPOLE=ON
		-DPKG_EXTRA-COMMAND=$(usex extra)
		-DPKG_EXTRA-COMPUTE=$(usex extra)
		-DPKG_EXTRA-DUMP=$(usex extra)
		-DPKG_EXTRA-FIX=$(usex extra)
		-DPKG_EXTRA-MOLECULE=$(usex extra)
		-DPKG_EXTRA-PAIR=$(usex extra)
		-DPKG_GRANULAR=ON
		-DPKG_KSPACE=ON
		-DFFT=FFTW3
		-DPKG_KOKKOS=$(usex kokkos)
		$(use kokkos && echo -DEXTERNAL_KOKKOS=ON)
		-DPKG_MANYBODY=ON
		-DPKG_MC=ON
		-DPKG_MEAM=ON
		-DPKG_MISC=ON
		-DPKG_MOLECULE=ON
		-DPKG_OPENMP=$(usex openmp)
		-DPKG_PERI=ON
		-DPKG_QEQ=ON
		-DPKG_REPLICA=ON
		-DPKG_RIGID=ON
		-DPKG_SHOCK=ON
		-DPKG_SRD=ON
		-DPKG_ML-PACE=$(usex pace)
		$(use pace && echo -DPACELIB_URL="file://${DISTDIR}/${PN}-pace-v.2023.11.25.fix2.tar.gz")
		-DPKG_PYTHON=$(usex python)
		-DPKG_MPIIO=$(usex mpi)
		-DPKG_VORONOI=ON
	)
	if use cuda || use opencl || use hip; then
		mycmakeargs+=( -DPKG_GPU=ON )
		use cuda && mycmakeargs+=( -DGPU_API=cuda )
		use opencl && mycmakeargs+=( -DGPU_API=opencl -DUSE_STATIC_OPENCL_LOADER=OFF )
		use hip && mycmakeargs+=( -DGPU_API=hip -DHIP_PATH="${EPREFIX}/usr" )
	else
		mycmakeargs+=( -DPKG_GPU=OFF )
	fi
	cmake_src_configure
	if use python; then
		pushd ../python || die
		distutils-r1_src_configure
		popd || die
	fi
}

src_compile() {
	cmake_src_compile
	if use python; then
		pushd ../python || die
		distutils-r1_src_compile
		popd || die
	fi
}

src_test() {
	cmake_src_test
	if use python; then
		pushd ../python || die
		distutils-r1_src_test
		popd || die
	fi
}

src_install() {
	cmake_src_install

	if use opencl; then
		dobin "${BUILD_DIR}/ocl_get_devices"
	fi

	if use cuda; then
		dobin "${BUILD_DIR}/nvc_get_devices"
	fi

	if use python; then
		pushd ../python || die
		distutils-r1_src_install
		popd || die
	fi

	if use examples; then
		for d in examples bench; do
			local LAMMPS_EXAMPLES="/usr/share/${PN}/${d}"
			insinto "${LAMMPS_EXAMPLES}"
			doins -r "${S}"/../${d}/*
		done
	fi
}
