package templates

import (
	corev1 "k8s.io/api/core/v1"
)

// Service defines the Kubernetes service for the xDS operator metrics
#Service: corev1.#Service & {
	#config: #Config
	
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:      "\(#config.metadata.name)-metrics"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		if #config.service.annotations != _|_ {
			annotations: #config.service.annotations
		}
	}
	
	spec: {
		type:     #config.service.type
		selector: #config.selector.labels
		ports: [
			{
				name:       "metrics"
				port:       #config.service.port
				targetPort: "metrics"
				protocol:   "TCP"
				if #config.service.type == "NodePort" && #config.service.nodePort != _|_ {
					nodePort: #config.service.nodePort
				}
			},
		]
	}
}
