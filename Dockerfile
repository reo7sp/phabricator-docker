FROM debian:jessie
MAINTAINER Oleg Morozenkov
ENV REFRESHED_AT 2015-08-29

RUN echo "deb-src http://httpredir.debian.org/debian jessie main" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y sudo ssh git supervisor mysql-client jq uwsgi-plugin-php php5-cli php5-mysql php5-gd php5-curl php5-json && \
	(test `php -r "echo extension_loaded('pcntl');"` -eq "1" || (apt-get source php5 && cd `ls -1F | grep '^php5-.*/$'`/ext/pcntl && phpize && ./configure && make && make install)) && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV PHABRICATOR_REFRESHED_AT 2015-08-29

WORKDIR /usr/src
RUN git clone -b stable --depth 1 https://github.com/phacility/libphutil.git && \
	git clone -b stable --depth 1 https://github.com/phacility/arcanist.git && \
	git clone -b stable --depth 1 https://github.com/phacility/phabricator.git && \
	rm -rf libphutil/.git && \
	rm -rf arcanist/.git && \
	rm -rf phabricator/.git

COPY phabricator-run.sh /phabricator-run.sh
COPY mysql-wait.sh /mysql-wait.sh
COPY phabricator-ssh-hook.sh /usr/libexec/phabricator-ssh-hook.sh
COPY sshd_config /etc/ssh/sshd_config
COPY sudoers /etc/sudoers
COPY supervisor.conf /etc/supervisor.conf
COPY uwsgi.conf /etc/uwsgi.conf
WORKDIR /usr/src/phabricator
RUN mkdir -p /var/run/sshd && \
	chmod 755 /usr/libexec/phabricator-ssh-hook.sh && \
	useradd phabricator-vcs && \
	chsh -s /bin/sh phabricator-vcs && \
	sed -i 's/phabricator-vcs:!!*:/phabricator-vcs:NP:/g' /etc/shadow && \
	bin/config set diffusion.ssh-user phabricator-vcs && \
	useradd phabricator-daemon && \
	chsh -s /bin/sh phabricator-daemon && \
	bin/config set phd.user phabricator-daemon && \
	bin/config set phd.taskmasters 1 && \
	bin/config set repository.default-local-path /var/lib/phabricator/repo && \
	bin/config set storage.local-disk.path /var/lib/phabricator/storage

VOLUME /var/lib/phabricator
EXPOSE 22 80
CMD ["sh", "/phabricator-run.sh"]
