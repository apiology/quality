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

update_from_cookiecutter: ## Bring in changes from template project used to create this repo
	bundle exec overcommit --uninstall
	IN_COOKIECUTTER_PROJECT_UPGRADER=1 cookiecutter_project_upgrader || true
	git checkout cookiecutter-template && git push && git checkout main
	git checkout main && git pull && git checkout -b update-from-cookiecutter-$$(date +%Y-%m-%d-%H%M)
	git merge cookiecutter-template || true
	bundle exec overcommit --install
	@echo
	@echo "Please resolve any merge conflicts below and push up a PR with:"
	@echo
	@echo '   gh pr create --title "Update from cookiecutter" --body "Automated PR to update from cookiecutter boilerplate"'
	@echo
	@echo
