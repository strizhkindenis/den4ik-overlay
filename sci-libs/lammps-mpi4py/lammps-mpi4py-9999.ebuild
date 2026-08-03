EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Python module to facilitate running LAMMPS using mpi4py"
HOMEPAGE="https://github.com/strizhkindenis/lammps-mpi4py"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/strizhkindenis/lammps-mpi4py.git"
else
	SRC_URI="https://github.com/strizhkindenis/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-python/mpi4py[${PYTHON_USEDEP}]
	sci-physics/lammps[python,mpi,${PYTHON_USEDEP}]
"
BDEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
