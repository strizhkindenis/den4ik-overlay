# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED=fortran
inherit cmake flag-o-matic fortran-2

DESCRIPTION="A suite of codes for electronic-structure calculations and modeling"
HOMEPAGE="https://www.quantum-espresso.org/"
SRC_URI="
	https://gitlab.com/QEF/q-e/-/archive/qe-${PV}/q-e-qe-${PV}.tar.bz2
		-> ${P}.tar.bz2
"
S="${WORKDIR}/q-e-qe-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="elpa fortran hdf5 libxc mpi openmp scalapack test"

# TODO: fix all external network dependencies"
RESTRICT="network-sandbox !test? ( test )"

# Use Gentoo virtuals and proper USE-flag propagation for parallelization
RDEPEND="
	sci-libs/fftw:3.0=[mpi?,openmp?]
	virtual/blas
	virtual/lapack
	elpa? ( sci-libs/elpa[mpi?,openmp?] )
	hdf5? ( sci-libs/hdf5:=[fortran,mpi?] )
	libxc? ( >=sci-libs/libxc-5.1.2:=[fortran] )
	mpi? ( virtual/mpi )
	scalapack? ( sci-libs/scalapack )
	sci-libs/wannier90[mpi?] 
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

pkg_setup() {
	fortran-2_pkg_setup
}

src_configure() {
	# Required for GCC 10+ to tolerate legacy Fortran standard violations in QE
	append-fflags -fallow-argument-mismatch

	local mycmakeargs=(
		-DQE_ENABLE_ELPA=$(usex elpa)
		-DQE_ENABLE_HDF5=$(usex hdf5)
		-DQE_ENABLE_LIBXC=$(usex libxc)
		-DQE_ENABLE_MPI=$(usex mpi)
		-DQE_ENABLE_OPENMP=$(usex openmp)
		-DQE_ENABLE_SCALAPACK=$(usex scalapack)
		-DQE_ENABLE_TEST=$(usex test)
		# Force system libraries to prevent sandbox violations and ensure optimizations
		-DQE_LAPACK_INTERNAL=OFF
		-DQE_WANNIER90_INTERNAL=OFF 
	)

	if use mpi; then
		mycmakeargs+=(
			-DCMAKE_C_COMPILER=mpicc
			-DCMAKE_Fortran_COMPILER=mpif90
		)
	fi

	cmake_src_configure
}

pkg_postinst() {
	elog "Quantum ESPRESSO has been installed successfully."
	elog "To run physical calculations, you will need pseudopotentials."
	elog "You can install them via Portage:"
	elog "  emerge sci-libs/pslibrary"
	elog "Or download them directly from: https://www.materialscloud.org/discover/sssp/table/efficiency"
}
