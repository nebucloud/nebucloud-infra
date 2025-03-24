package templates

import (
	batchv1 "k8s.io/api/batch/v1"
)

// TestJob defines a Kubernetes job for testing the xDS operator
#TestJob: batchv1.#Job & {
	#config: #Config
	
	apiVersion: "batch/v1"
	kind:       "Job"
	metadata: {
		name:      "\(#config.metadata.name)-test"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
	}
	// Handle annotations separately to avoid optional field reference error
	if #config.metadata.annotations != _|_ {
		metadata: annotations: #config.metadata.annotations
	}
	
	spec: {
		backoffLimit: 0
		template: {
			metadata: {
				labels: #config.metadata.labels
			}
			spec: {
				serviceAccountName: #config.serviceAccount.name
				containers: [
					{
						name:            "test"
						image:           "\(#config.test.image.repository):\(#config.test.image.tag)"
						imagePullPolicy: #config.test.image.pullPolicy
						command: [
							"curl",
							"-sSLf",
							"http://\(#config.metadata.name)-metrics:\(#config.service.port)/metrics",
						]
					},
				]
				restartPolicy: "Never"
			}
		}
	}
}