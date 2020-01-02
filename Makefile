.PHONY: spec feature

all: localtest

localtest:
	@bundle exec rake localtest

test:
	@bundle exec rake test

feature:
	@bundle exec rake feature

spec:
	@bundle exec rake spec

rubocop:
	@bundle exec rake rubocop

punchlist:
	@bundle exec rake punchlist

quality:
	@bundle exec rake quality
