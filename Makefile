
prefix ?= /usr/local

.PHONY: default
default: all

.PHONY: all
all: man bash-completion

.PHONY: deb
deb:
	debuild -uc -us -tc

.PHONY: man
man: git-hub.1

git-hub.1: man.rst
	rst2man --exit-status=1 $^ > $@ || ($(RM) $@ && false)

bash-completion: generate-bash-completion git-hub
	./$^ > $@ || ($(RM) $@ && false)

.PHONY: install
install: git-hub git-hub.1 ftdetect.vim bash-completion
	install -m 755 -D git-hub $(DESTDIR)$(prefix)/bin/git-hub
	sed -i 's/^VERSION = "git-hub v?"$$/VERSION = "git-hub v'`git describe`'"/' \
			$(DESTDIR)$(prefix)/bin/git-hub
	install -m 644 -D git-hub.1 $(DESTDIR)$(prefix)/share/man/man1/git-hub.1
	install -m 644 -D ftdetect.vim \
		$(DESTDIR)$(prefix)/share/vim/addons/ftdetect/githubmsg.vim
	install -m 644 -D bash-completion $(DESTDIR)/etc/bash_completion.d/git-hub

.PHONY: release
release:
	@defaultver=`sed -n '1 s/^git-hub (\(.*\)) .*/\1/p' debian/changelog`; \
	read -p "Enter version [$$defaultver]: " version; \
	test -z $$version && version=$$defaultver; \
	msg=`echo $$version | sed 's/v/Version /;s/rc/ Release Candidate /'`; \
	set -x; \
	git tag -a -m "$$msg" $$version

.PHONY: clean
clean:
	$(RM) git-hub.1 bash-completion

