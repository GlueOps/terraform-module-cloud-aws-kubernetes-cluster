# GlueOps specific Notes

- This TF test uses the `tf-aws-module` aws account within the "rocks" organization.
- Create the role as outlined in the module README.md
- Inject the values below for AWS as github action secrets:
```bash
export AWS_SECRET_ACCESS_KEY
```

- Test is managed by this workflow: `aws-cloud-regression-suite.yml`