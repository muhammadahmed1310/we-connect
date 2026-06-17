# Women Emerging Management Hub

This is currently the management hub for Women Emerging.
Eventually, it will also be the complete website, but for the moment it
is just the management hub.

## User roles and permissions

### Roles

Users on the system will have one or more roles assigned. Currently, the major roles are:

* Admin - overall superuser
* Staff - Women Emerging staff member
* Explorer - user who is a member or leader of an expedition (managed or solo)

Eventually, we will also have:

* Subscriber - user who has signed up but not yet joined an expedition
* Users who are not logged in:
    * Contacts - CRM users who we interact with but do not log into the system
    * Public - users who are not logged in but looking at the website

For the moment, there is no way to sign up for the system, so all users are created by the admin.

Roles define the data the user can access and also their specific views and actions. This 
includes:
* The main menu displayed on login
* The dashboard displayed on login

### Permissions

Admin and staff are allowed to see and edit most everything. We may restrict staff permissions
in the future for safety reasons.

Explorers are allowed to see and edit their own data, and to read most expedition information for
their expeditions:

* view the expedition data (including activities, content, locations, and organizations)
* activities, content, etc should have a flag for draft or published, and explorers should
  only see published
* _see all the members of the expedition???_

If an explorer has a expedition_role on an expedition of **leader**, they can also:

* edit the expedition data (including activities, content, locations, and organizations)
* see and edit some or all of the draft activities, content, etc
* see all the members of the expedition
* _add expedition members??_
* _delete expedition members??_
* _edit member user data??_

## Versioning

The main objects are versioned, but the associations between them are not. This means that
if you change an object, you can see the history of the object, but you cannot see the history
of the associations between objects.

Main objects that are versioned include:

* expeditions
* activities
* content
* locations
* organizations
* users

_We need to decide if there are associations that should be versioned. For example, do we need to
track changes in users associated with an expedition?_

## Production Servers

Currently we are running staging and production servers on Google Cloud Platform.
These include:

* A mysql database for each server
* A compute engine running ubuntu 24.04

## Scripts

There are a number of scripts in the scripts directory that detail the setup of
the development environment and the production servers. 
