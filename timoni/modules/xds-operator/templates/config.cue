package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// The kubeVersion is a required field, set at apply-time
	// via timoni.cue by querying the user's Kubernetes API.
	kubeVersion!: string
	// Using the kubeVersion you can enforce a minimum Kubernetes minor version.
	// By default, the minimum Kubernetes version is set to 1.20.
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}
	// The moduleVersion is set from the user-supplied module version.
	// This field is used for the `app.kubernetes.io/version` label.
	moduleVersion!: string
	// The Kubernetes metadata common to all resources.
	// The `metadata.name` and `metadata.namespace` fields are
	// set from the user-supplied instance name and namespace.
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	// The labels allows adding `metadata.labels` to all resources.
	// The `app.kubernetes.io/name` and `app.kubernetes.io/version` labels
	// are automatically generated and can't be overwritten.
	metadata: labels: timoniv1.#Labels
	// The annotations allows adding `metadata.annotations` to all resources.
	metadata: annotations?: timoniv1.#Annotations
	// The selector allows adding label selectors to Deployments and Services.
	// The `app.kubernetes.io/name` label selector is automatically generated
	// from the instance name and can't be overwritten.
	selector: timoniv1.#Selector & {#Name: metadata.name}
	// The image allows setting the container image repository,
	// tag, digest and pull policy.
	// The default image repository and tag is set in `values.cue`.
	image!: timoniv1.#Image
	// The resources allows setting the container resource requirements.
	// By default, the container requests 10m CPU and 32Mi memory.
	resources: timoniv1.#ResourceRequirements & {
		requests: {
			cpu: *"10m" | timoniv1.#CPUQuantity
			memory: *"32Mi" | timoniv1.#MemoryQuantity
		}
	}
	// The number of pods replicas.
	// By default, the number of replicas is 1.
	replicas: *1 | int & >0
	// The securityContext allows setting the container security context.
	// By default, the container is denined privilege escalation.
	securityContext: corev1.#SecurityContext & {
		allowPrivilegeEscalation: *false | true
		privileged:               *false | true
		capabilities: {
			drop: *["ALL"] | [string]
			add?: [...string]
		}
		readOnlyRootFilesystem?: bool
		runAsNonRoot?:           bool
		runAsUser?:              int
	}

	// xDS server connection settings
	xdsServer: {
		// The address of the xDS server to connect to
		address: string | *"xds-server.xds-system.svc.cluster.local:18000"
		
		// The node ID to use when communicating with the xDS server
		nodeID: string | *"xds-operator"
	}
	
	// RBAC settings
	rbac: {
		// Create RBAC resources
		create: bool | *true
		
		// Custom rules for the cluster role
		rules: [...{
			apiGroups: [...string]
			resources: [...string]
			verbs:     [...string]
		}]
	}
	
	// The service allows setting the Kubernetes Service annotations and port.
	// By default, the HTTP port is 80.
	service: {
		// Whether to create a Service resource
		create:      bool | *true
		type:        *"ClusterIP" | "NodePort" | "LoadBalancer"
		annotations?: timoniv1.#Annotations
		port:         *80 | int & >0 & <=65535
		nodePort?:    int & >=30000 & <=32767
	}
	
	// Health probe settings
	healthProbe: {
		liveness: {
			path:                string | *"/healthz"
			port:                int | *8081
			initialDelaySeconds: int | *15
			periodSeconds:       int | *20
		}
		readiness: {
			path:                string | *"/readyz"
			port:                int | *8081
			initialDelaySeconds: int | *5
			periodSeconds:       int | *10
		}
	}
	
	// Service account configuration
	serviceAccount: {
		// Whether to create a service account
		create: bool | *true
		
		// The name of the service account to use
		name: string | *"\(metadata.name)"
		
		// Annotations to add to the service account
		annotations?: {[string]: string}
	}
	
	// CRD installation configuration
	crds: {
		// Whether to install CRDs
		create: bool | *true
	}

	// Pod optional settings.
	podAnnotations?: {[string]: string}
	podSecurityContext?: corev1.#PodSecurityContext
	imagePullSecrets?: [...timoniv1.#ObjectReference]
	tolerations?: [...corev1.#Toleration]
	affinity?: corev1.#Affinity
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]
	
	// Test Job disabled by default.
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
	
	// App settings.
	message: string
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config
	objects: {
		sa: #ServiceAccount & {#config: config}
		svc: #Service & {#config: config}
		cm: #ConfigMap & {#config: config}
		deploy: #Deployment & {
			#config: config
			#cmName: objects.cm.metadata.name
		}
	}
	tests: {
		"test-svc": #TestJob & {#config: config}
	}
}