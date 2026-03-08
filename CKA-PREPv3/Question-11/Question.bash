Create the following resources exactly as requested.

Question 11 | Create Secret and mount into Pod

In Namespace secret:
1. Create Pod secret-pod using image busybox:1 and keep it running.
   - For example, use a command like: sleep 1d

2. Create the existing Secret from this file:
   - /opt/course/11/secret1.yaml

3. Mount that Secret into the Pod:
   - mount path: /tmp/secret1
   - mount must be read-only

4. Create Secret secret2 with these key/value pairs:
   - user=user1
   - pass=1234

5. Expose values from secret2 inside the container as environment variables:
   - APP_USER
   - APP_PASS

Notes:
- All resources must be created in Namespace secret.
- The Pod name must be secret-pod.
- The image must be busybox:1.
- The mounted Secret must be the existing Secret created from /opt/course/11/secret1.yaml.
- APP_USER must come from key user in Secret secret2.
- APP_PASS must come from key pass in Secret secret2.
