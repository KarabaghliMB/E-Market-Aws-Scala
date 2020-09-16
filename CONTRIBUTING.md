# Contribution rules

## Core product team

* Product Owner: [Arun Aishwarya](https://gaufre.informatique.univ-paris-diderot.fr/poca-a)
* Development Team:
  * [Bouchra Bennani](https://gaufre.informatique.univ-paris-diderot.fr/poca-b)
  * [Carl Christensen](https://gaufre.informatique.univ-paris-diderot.fr/poca-c)
* SCRUM master: Diane Delaunay

## Types of gitlab issues

Developers are assigned tasks. Tasks should be as small as possible. The amount of work needed to complete the task is estimated by the development team:

* XS: very small task. One or a few lines to change, no risk.
* S: small task. Simple and quick to complete.
* M: medium task. No more than 2 or 3 hours of work.
* L: large task. It is not easy to imagine what needs to be changed to complete the task. It should be defined more precisely or/and broken down to smaller tasks if possible.
* XL: very large task. This task is very complex. It must be broken down to smaller pieces.

Tasks related to a common feature are linked to a story describing the feature.

Bugs should be fixed before new features are added to the product.

## Branching

Each task is implemented on a separate branch named `<contributor>-<task name>` (e.g. `bouchra-contributing`).

Changes are integrated to the branch `master` after the following steps:

* another member of the development team approved a code review ;
* the tests are passing ;
* the branch has been rebased on the branch `master`.

See https://medium.com/faun/how-to-rebase-and-merge-with-git-a9c29b2172ad.
