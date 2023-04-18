# GlueOps specific Notes

- This TF test uses the `venkata-captain` AWS account but eventually needs to be migrated to the `tf-aws-module` aws account within the rocks organization.
- Create the role as outlined in the module docs.
- inject the values below for AWS as github action secrets:
```bash
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION
```


- `run.sh` is where all the heavy logic happens.