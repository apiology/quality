all: localtest

localtest:
	bundle exec rake localtest

quality:
	bundle exec rake quality
