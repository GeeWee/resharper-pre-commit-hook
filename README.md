# reshaper-pre-commit-hook
Resharper format pre-commit hook


#TODO:
- Add instructions (one-liner) on how to install directly from git
- Rewrite powershell to bash script
- Currently it tries to git add deleted files, which makes it fail

```
Restaging files: Scripts/datagen-deploy.ps1
Scripts/deploy-script.ps1
Scripts/install-git-hook.ps1
Scripts/k8s/context-service.yaml
Scripts/k8s/datagenerator.yaml
Scripts/k8s/golddata.yaml
Scripts/k8s/harmonizer.yaml
Scripts/k8s/kustomization.yaml
Scripts/shared-functions.ps1
git add Scripts/datagen-deploy.ps1 Scripts/deploy-script.ps1 Scripts/install-git-hook.ps1 Scripts/k8s/context-service.yaml Scripts/k8s/datagenerator.yaml Scripts/k8s/golddata.yaml Scripts/k8s/harmonizer.yaml Scripts/k8s/kustomization.yaml Scripts/shared-functions.ps1 
fatal: pathspec 'Scripts/install-git-hook.ps1' did not match any files
"xargs -t -l git add" command filed with exit code 123.
```