from kubernetes import client, config
import os

def main():
    # Load kubeconfig for connecting to the cluster (works if kubeconfig is set up locally)
    config.load_kube_config()

    # Define the namespace to check (change to your namespace if needed)
    namespace = "default"

    # Create the Kubernetes API client
    v1 = client.CoreV1Api()

    print(f"Fetching pods in namespace: {namespace}")
    
    # Get the list of pods in the specified namespace
    pods = v1.list_namespaced_pod(namespace)

    # Check each pod's status
    for pod in pods.items:
        pod_name = pod.metadata.name
        pod_status = pod.status.phase

        print(f"Pod: {pod_name}, Status: {pod_status}")

        # If the pod is not in the "Running" state
        if pod_status != "Running":
            # Fetch the pod logs
            logs = v1.read_namespaced_pod_log(pod_name, namespace)

            # Save the logs to a file named <pod-name>-logs.txt
            log_filename = f"{pod_name}-logs.txt"
            with open(log_filename, "w") as log_file:
                log_file.write(logs)

            print(f"Logs for pod {pod_name} saved to {log_filename}")
        else:
            print(f"Pod {pod_name} is running.")

if __name__ == "__main__":
    main()

