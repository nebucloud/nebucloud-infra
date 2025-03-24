package main

import (
	"github.com/nebucloud/xds-operator/templates"
)

// Default values, can be partially overridden with --values.
values: templates.#Config & {
	// xDS operator image defaults
	image: {
		repository: "oci://ghcr.io/nebucloud/xds-operator"
		tag:        "latest"
		digest:     ""  // Add empty digest
		pullPolicy: "IfNotPresent"
	}

	// Default resources for the operator container
	resources: {
		requests: {
			cpu:    "100m"
			memory: "128Mi"
		}
		limits: {
			cpu:    "500m"
			memory: "256Mi"
		}
	}

	// xDS server connection settings
	xdsServer: {
		address: "xds-server.xds-system.svc.cluster.local:18000"
		nodeID:  "xds-operator"
	}

	// RBAC settings
	rbac: {
		create: true
		rules: [
			{
				apiGroups: ["xds.nebucloud.io"]
				resources: ["listeners", "clusters", "routes", "endpoints"]
				verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
			},
			{
				apiGroups: ["xds.nebucloud.io"]
				resources: ["listeners/status", "clusters/status", "routes/status", "endpoints/status"]
				verbs: ["get", "update", "patch"]
			},
			{
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			},
		]
	}

	// Service account settings
	serviceAccount: {
		create: true
		name:   "xds-operator"
	}

	// Service settings for metrics
	service: {
		create: true
		type:   "ClusterIP"
		port:   8080
	}

	// Health probe settings
	healthProbe: {
		liveness: {
			path:                "/healthz"
			port:                8081
			initialDelaySeconds: 15
			periodSeconds:       20
		}
		readiness: {
			path:                "/readyz"
			port:                8081
			initialDelaySeconds: 5
			periodSeconds:       10
		}
	}

	// CRD installation
	crds: {
		create: true
	}

	// Security context
	securityContext: {
		allowPrivilegeEscalation: false
		capabilities: {
			drop: ["ALL"]
		}
		readOnlyRootFilesystem: true
		runAsNonRoot:           true
		runAsUser:              1000
	}

	// Test settings
	test: {
		enabled: false
		image: {
			repository: "curlimages/curl"
			tag:        "latest"
			digest:     ""  // Add empty digest
			pullPolicy: "IfNotPresent"
		}
	}

	// Required message field
	message: "xDS Operator"
}