all: localtest

localtest:
	@bundle exec rake localtest

test:
	@bundle exec rake test

rubocop:
	@bundle exec rake rubocop

punchlist:
	@bundle exec rake punchlist

quality:
	@bundle exec rake quality
