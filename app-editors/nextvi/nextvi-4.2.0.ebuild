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
RDEPEND="
	app-eselect/eselect-vi
"

src_compile() {
	./cbuild.sh build
}

src_install() {
	newbin vi nextvi
	newman vi.1 nextvi.1
	dodoc README
}

pkg_postinst() {
	einfo "Updating ${EPREFIX}/usr/bin/vi symlink"
	eselect vi update --if-unset
}

pkg_postrm() {
	einfo "Updating ${EPREFIX}/usr/bin/vi symlink"
	eselect vi update --if-unset
}
