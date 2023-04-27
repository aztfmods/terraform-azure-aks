.PHONY: complete container-registry node-pools simple

complete:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/complete

simple:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/simple

node-pools:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/node-pools

container-registry:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/container-registry
