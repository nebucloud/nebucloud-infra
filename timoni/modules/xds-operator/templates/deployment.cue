package templates

import (
	appsv1 "k8s.io/api/apps/v1"
)

// Deployment defines the xDS operator deployment
#Deployment: appsv1.#Deployment & {
	#config: #Config
	
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      #config.metadata.name
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
	}
	// Handle annotations separately to avoid optional field reference error
	if #config.metadata.annotations != _|_ {
		metadata: annotations: #config.metadata.annotations
	}
	
	spec: {
		replicas: #config.replicas
		selector: matchLabels: #config.selector.labels
		template: {
			metadata: {
				labels: #config.selector.labels
				if #config.podAnnotations != _|_ {
					annotations: #config.podAnnotations
				}
			}
			spec: {
				serviceAccountName: #config.serviceAccount.name
				
				if #config.imagePullSecrets != _|_ {
					imagePullSecrets: #config.imagePullSecrets
				}
				
				if #config.podSecurityContext != _|_ {
					securityContext: #config.podSecurityContext
				}
				
				if #config.tolerations != _|_ {
					tolerations: #config.tolerations
				}
				
				if #config.affinity != _|_ {
					affinity: #config.affinity
				}
				
				if #config.topologySpreadConstraints != _|_ {
					topologySpreadConstraints: #config.topologySpreadConstraints
				}
				
				containers: [
					{
						name:            "operator"
						image:           "\(#config.image.repository):\(#config.image.tag)"
						imagePullPolicy: #config.image.pullPolicy
						
						args: [
							"--metrics-bind-address=:8080",
							"--health-probe-bind-address=:\(#config.healthProbe.liveness.port)",
							"--xds-server-address=\(#config.xdsServer.address)",
							"--xds-node-id=\(#config.xdsServer.nodeID)",
						]
						
						resources: {
							if #config.resources.requests != _|_ {
								requests: #config.resources.requests
							}
							if #config.resources.limits != _|_ {
								limits: #config.resources.limits
							}
						}
						
						ports: [
							{
								name:          "metrics"
								containerPort: 8080
								protocol:      "TCP"
							},
							{
								name:          "health"
								containerPort: #config.healthProbe.liveness.port
								protocol:      "TCP"
							},
						]
						
						livenessProbe: {
							httpGet: {
								path: #config.healthProbe.liveness.path
								port: #config.healthProbe.liveness.port
							}
							initialDelaySeconds: #config.healthProbe.liveness.initialDelaySeconds
							periodSeconds:       #config.healthProbe.liveness.periodSeconds
						}
						
						readinessProbe: {
							httpGet: {
								path: #config.healthProbe.readiness.path
								port: #config.healthProbe.readiness.port
							}
							initialDelaySeconds: #config.healthProbe.readiness.initialDelaySeconds
							periodSeconds:       #config.healthProbe.readiness.periodSeconds
						}
						
						securityContext: #config.securityContext
					},
				]
				
				securityContext: {
					runAsNonRoot: true
					seccompProfile: {
						type: "RuntimeDefault"
					}
				}
				
				terminationGracePeriodSeconds: 10
			}
		}
	}
}