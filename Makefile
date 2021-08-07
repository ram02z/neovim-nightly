all: clone bootstrap template build sign

clone:
	bash scripts/clone.sh

template:
	bash scripts/template.sh

build:
	./void-packages/xbps-src -m ./void-packages/masterdir-musl binary-bootstrap x86_64-musl
	./void-packages/xbps-src -m ./void-packages/masterdir-musl pkg neovim-nightly

sign:
	xbps-rindex --privkey private.pem --sign --signedby "Omar Zeghouani" ./void-packages/hostdir/binpkgs
	xbps-rindex --privkey private.pem --sign-pkg ./void-packages/hostdir/binpkgs/*.xbps

tree:
	bash scripts/tree.sh $$PWD/void-packages/hostdir/binpkgs $$PWD/void-packages/hostdir/binpkgs/ https://ram02z.github.io/nvim-musl

clean:
	rm -rf tmp void-packages/tmp void-packages/srcpkgs/nvim
	./void-packages/xbps-src clean
	rm void-packages/hostdir/**/*.html
