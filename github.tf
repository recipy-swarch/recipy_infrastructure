terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
    token = var.github_token
    owner = "recipy-swarch"
}


# Define the GitHub organization
resource "github_organization_settings" "org_settings" {
    billing_email = "jvasquezp@unal.edu.co"
    company = "recipy-swarch"
    # blog = "https://example.com"
    # email = "jvasquezp@unal.edu.co" # We'll change this later when we have our email service running
    #twitter_username = "Test"
    location = "Colombia"
    name = "Recipy"
    description = "Recipy"
    has_organization_projects = true
    has_repository_projects = true
    default_repository_permission = "read"
    members_can_create_repositories = false
    members_can_create_public_repositories = false
    members_can_create_private_repositories = false
    members_can_create_internal_repositories = false

    # Pages are a way to host static websites directly from a GitHub repository.
    members_can_create_pages = true
    members_can_create_public_pages = true
    members_can_create_private_pages = true

    members_can_fork_private_repositories = false
    web_commit_signoff_required = false # Homework for JD: Teach everyone hot to add a GPG key to their GitHub account
    advanced_security_enabled_for_new_repositories = false

    # Dependabot is a tool that helps you keep your dependencies up to date.
    # I'm not sure if we want to enable this for new repositories, but let's leave it as false for now.
    dependabot_alerts_enabled_for_new_repositories=  false
    dependabot_security_updates_enabled_for_new_repositories = false
    dependency_graph_enabled_for_new_repositories = false
    
    # Secret scanning is a feature that scans your code for sensitive information, such as API keys and passwords.
    secret_scanning_enabled_for_new_repositories = true
    secret_scanning_push_protection_enabled_for_new_repositories = true
}

# Team
resource "github_team" "recipy_team" {
  name        = "recipy-team"
  description = "El equipo de desarrollo de Recipy"
}

# Adding members to the organization
# Add a user to the organization
resource "github_membership" "membership_for_fnovoas" {
  username = "fnovoas"
  role     = "member"
}
resource "github_membership" "membership_for_jvasquezp" {
  username = "jvasquezp"
  role     = "admin"
}
resource "github_membership" "membership_for_johnrua17" {
  username = "johnrua17"
  role     = "member"
}
resource "github_membership" "membership_for_Emperator777" {
  username = "Emperator777"
  role     = "member"
}
resource "github_membership" "membership_for_luisdiazv" {
  username = "luisdiazv"
  role     = "member"
}
resource "github_membership" "membership_for_CrockedSpecs" {
  username = "CrockedSpecs"
  role     = "member"
}

resource "github_team_members" "recipy_team_members" {
  team_id  = github_team.recipy_team.id

  members {
    username = "fnovoas"
    role     = "member"
  }
  members {
    username = "jvasquezp"
    role     = "maintainer"
  }
  members {
    username = "johnrua17"
    role     = "member"
  }
  members {
    username = "Emperator777"
    role     = "member"
  }
  members {
    username = "luisdiazv"
    role     = "member"
  }
  members {
    username = "CrockedSpecs"
    role     = "member"
  }
}

# TODO: Define the teams and their members

# Repository for the project
resource "github_repository" "recipy_repo" {
  name        = "recipy"
  description = "Recipy is your go-to solution for managing and sharing recipes. Our platform allows you to easily create, organize, and share your favorite recipes with friends and family. Whether you're a seasoned chef or just starting out in the kitchen, Recipy has everything you need to make cooking fun and enjoyable."
  #homepage_url - (Optional) URL of a page describing the project.

  # Repository configuration
  #private    = false
  visibility = "public"
  has_issues = true
  has_discussions = true
  has_projects = true #It should be useful to use them. But I haven't used them yet.
  has_wiki = true
  #is_template = false

  # Settings for the repository
  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = false # Ugh, I hate rebase. I don't want to use it. It increases the possibility of merge conflicts and makes the commit history harder to read.
  allow_auto_merge = true # I preffer to use manual merge, but I think this is a good option to have.
  #squash_merge_commit_title = "COMMIT_OR_PR_TITLE"
  #squash_merge_commit_message = "COMMIT_MESSAGES" # Another option is "PR_BODY" or "BLANK", Let's leave it as COMMIT_MESSAGES for now.
  #merge_commit_title = "PR_TITLE and PR_BODY" # I don't know what this is, but let's leave it as the default for now.
  #merge_commit_message = "PR_BODY"
  delete_branch_on_merge = true # I think this is a good option to have. It helps to keep the repository clean and organized.

  #web_commit_signoff_required = false #Already set in the organization settings
  has_downloads = false # It's deprecated. I don't think we need it.

  # Initial commit with a README.md file and gitignore for Visual Studio
  auto_init = true
  gitignore_template = "VisualStudio"

  #default_branch = "main" # main is default anyway.
  archived = false # It's stil a live project. So let's leave it as false.
  archive_on_destroy = true # I don't want to lose the repository if I destroy it.

  # Maybe in the future we can add a GitHub Pages site to the repository.
  # pages {
  #   source {
  #     branch = "main"
  #     path   = "/docs"
  #   }
  # }

  # Enable vulnerability alerts and automated security fixes
  security_and_analysis {
    #advanced_security {
    #  status = "enabled" # I have no idea what this is, but let's leave it as enabled for now.
    #}
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }  
  vulnerability_alerts = true # I haven't use this yet, let's try it.
  ignore_vulnerability_alerts_during_read = false 

  allow_update_branch = true # It sounds useful to have this option. But I don't know if we need it.
}

resource "github_repository_collaborators" "recipy_repo_collaborators" {
  repository = github_repository.recipy_repo.name

  team {
    permission = "push"
    team_id = github_team.recipy_team.id
  }
}

# Create the "development" branch
resource "github_branch" "development" {
  repository = github_repository.recipy_repo.name
  branch     = "development"
  #source_branch = "main" # This is the default branch.
}

resource "github_branch_protection" "recipy_repo_protection" {
  repository_id  = github_repository.recipy_repo.name
  pattern        = "main"

  enforce_admins          = true          # Even admins have to follow the rules.
  require_signed_commits = false  # Homework for JD: Teach everyone hot to add a GPG key to their GitHub account
  required_linear_history = false # Teacher's recommendation
  require_conversation_resolution = true # It's important to address all comments before merging the PR.
  
  required_status_checks {
    strict   = true
    # contexts = ["ci/circleci: build"] # We can add this later when we have a CI/CD pipeline.
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true # Keep the review process fresh and up-to-date.
    # restrict_dimissals and dimissal_restrictions wont be used, as I think everyone should be able to dismiss a review.
    # pull_request_bypassers = [] # Nobody will be able to bypass the review process.
    require_code_owner_reviews      = false
    required_approving_review_count = 3 # We are 6, the team is small, so I think before a stable build we should all approve the PR.
    require_last_push_approval      = true # If thinks go wrong, we can set this to false.
  }

  # force_push_bystanders = [] # Nobody will be able to bypass the review process.
  allows_force_pushes = false # I don't want to allow force pushes. It's a bad practice and can cause problems.
  allows_deletions = false
  lock_branch = false # I don't want to lock the branch. We nee to be able to PR to it.
}


resource "github_branch_protection" "recipy_repo_protection_development" {
  repository_id  = github_repository.recipy_repo.name
  pattern        = "development"

  enforce_admins          = true          # Even admins have to follow the rules.
  require_signed_commits = false  # Homework for JD: Teach everyone hot to add a GPG key to their GitHub account
  required_linear_history = false # Teacher's recommendation
  require_conversation_resolution = true # It's important to address all comments before merging the PR.
  
  required_status_checks {
    strict   = true
    # contexts = ["ci/circleci: build"] # We can add this later when we have a CI/CD pipeline.
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true # Keep the review process fresh and up-to-date.
    # restrict_dimissals and dimissal_restrictions wont be used, as I think everyone should be able to dismiss a review.
    # pull_request_bypassers = [] # Nobody will be able to bypass the review process.
    require_code_owner_reviews      = false
    required_approving_review_count = 1 # Only one person needs to approve the PR.
    require_last_push_approval      = true # If thinks go wrong, we can set this to false.
  }

  # force_push_bystanders = [] # Nobody will be able to bypass the review process.
  allows_force_pushes = false # I don't want to allow force pushes. It's a bad practice and can cause problems.
  allows_deletions = false
  lock_branch = false # I don't want to lock the branch. We nee to be able to PR to it.
}

# Repository for the project
resource "github_repository" "recipy_infrastructure_repo" {
  name        = "recipy_infrastructure"
  description = "Recipy is your go-to solution for managing and sharing recipes. Our platform allows you to easily create, organize, and share your favorite recipes with friends and family. Whether you're a seasoned chef or just starting out in the kitchen, Recipy has everything you need to make cooking fun and enjoyable."
  #homepage_url - (Optional) URL of a page describing the project.

  # Repository configuration
  #private    = false
  visibility = "public"
  has_issues = true
  has_discussions = true
  has_projects = true #It should be useful to use them. But I haven't used them yet.
  has_wiki = true
  #is_template = false

  # Settings for the repository
  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = false # Ugh, I hate rebase. I don't want to use it. It increases the possibility of merge conflicts and makes the commit history harder to read.
  allow_auto_merge = true # I preffer to use manual merge, but I think this is a good option to have.
  #squash_merge_commit_title = "COMMIT_OR_PR_TITLE"
  #squash_merge_commit_message = "COMMIT_MESSAGES" # Another option is "PR_BODY" or "BLANK", Let's leave it as COMMIT_MESSAGES for now.
  #merge_commit_title = "PR_TITLE and PR_BODY" # I don't know what this is, but let's leave it as the default for now.
  #merge_commit_message = "PR_BODY"
  delete_branch_on_merge = true # I think this is a good option to have. It helps to keep the repository clean and organized.

  #web_commit_signoff_required = false #Already set in the organization settings
  has_downloads = false # It's deprecated. I don't think we need it.

  # Initial commit with a README.md file and gitignore for Visual Studio
  auto_init = true
  gitignore_template = "Terraform"

  #default_branch = "main" # main is default anyway.
  archived = false # It's stil a live project. So let's leave it as false.
  archive_on_destroy = true # I don't want to lose the repository if I destroy it.

  # Maybe in the future we can add a GitHub Pages site to the repository.
  # pages {
  #   source {
  #     branch = "main"
  #     path   = "/docs"
  #   }
  # }

  # Enable vulnerability alerts and automated security fixes
  security_and_analysis {
    #advanced_security {
    #  status = "enabled" # I have no idea what this is, but let's leave it as enabled for now.
    #}
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }  
  vulnerability_alerts = true # I haven't use this yet, let's try it.
  ignore_vulnerability_alerts_during_read = false 

  allow_update_branch = true # It sounds useful to have this option. But I don't know if we need it.
}

resource "github_branch_protection" "recipy_infrastructure_repo_protection" {
  repository_id  = github_repository.recipy_infrastructure_repo.name
  pattern        = "main"

  enforce_admins         = false          # Even admins have to follow the rules.
  require_signed_commits = true  # Homework for JD: Teach everyone hot to add a GPG key to their GitHub account
  required_linear_history = false # Teacher's recommendation
  require_conversation_resolution = true # It's important to address all comments before merging the PR.
  
  required_status_checks {
    strict   = true
    # contexts = ["ci/circleci: build"] # We can add this later when we have a CI/CD pipeline.
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true # Keep the review process fresh and up-to-date.
    # restrict_dimissals and dimissal_restrictions wont be used, as I think everyone should be able to dismiss a review.
    # pull_request_bypassers = [] # Nobody will be able to bypass the review process.
    require_code_owner_reviews      = false
    required_approving_review_count = 5 # We are 6, the team is small, so I think before a stable build we should all approve the PR.
    require_last_push_approval      = true # If thinks go wrong, we can set this to false.
  }

  force_push_bypassers = ["/jvasquezp"] # Nobody will be able to bypass the review process.
  allows_force_pushes = false # I don't want to allow force pushes. It's a bad practice and can cause problems.
  allows_deletions = false
  lock_branch = false # I don't want to lock the branch. We nee to be able to PR to it.
}

resource "github_repository_collaborators" "recipy_infra_collaborators" {
  repository = github_repository.recipy_infrastructure_repo.name

  team {
    team_id    = github_team.recipy_team.id
    permission = "push"     # o "admin"/"maintain" según necesidades
  }
}

// Repositorio para la app móvil
resource "github_repository" "recipy_mobile_repo" {
  name        = "recipy-mobile"
  description = "Repositorio para la aplicación móvil de Recipy"
  visibility  = "public"

  has_issues       = true
  has_wiki         = true
  has_discussions  = true
  has_projects     = true
  delete_branch_on_merge = true

  auto_init           = false
  # gitignore_template  = "Terraform"
  archive_on_destroy  = true

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
  vulnerability_alerts                 = true
  ignore_vulnerability_alerts_during_read = false
  allow_update_branch                 = true
}

// Dar acceso al equipo “recipy-team” al repositorio movíl
resource "github_repository_collaborators" "recipy_mobile_collaborators" {
  repository = github_repository.recipy_mobile_repo.name

  team {
    team_id    = github_team.recipy_team.id
    permission = "push"  # o "admin"/"maintain" según necesidades
  }
}