module github.com/nebucloud/nebucloud-infra

go 1.22.2

replace (
	github.com/nebucloud/nebucloud-infra/operator => ./operator
	github.com/nebucloud/nebucloud-infra/pkg => ./pkg
)
