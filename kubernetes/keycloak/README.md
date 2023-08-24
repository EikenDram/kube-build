# Keycloak

This is access manager for cluster resources using singe sign-on policy

## Install

Install from helm chart

## Setup

Need to add a new realm called "cluster" and create a client called "oauth2-proxy", and add client scopes with mapping for audience? and groups

Also create a role "cluster-admin" and change protocol to allow auth for users with this group

Will do this manually for now, but can probably export configuration later and import it during installation