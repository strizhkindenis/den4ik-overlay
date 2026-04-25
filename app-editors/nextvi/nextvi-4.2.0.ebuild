EAPI=8
DESCRIPTION="A small vi/ex terminal text editor (neatvi rewrite)"
HOMEPAGE="https://github.com/kyx0r/nextvi"
SRC_URI="
	https://github.com/kyx0r/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
PATCHES=(
	"${FILESDIR}"/config.patch
)

src_compile() {
	./cbuild.sh build
}

src_install() {
	dobin vi
	doman vi.1
	dodoc README
}
