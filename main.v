(* This script uses the Coqine plugin to export all files and parts. *)

Require Coqine.

Set Printing Universes.

Dedukti Set Destination "_build/out".

Dedukti Enable Debug.
Dedukti Set Debug "_build/debug.out".

Dedukti Set Encoding "polymorph".

Dedukti Filter Out "Coq.Init.Logic.rew_ex".
Dedukti Filter Out "Coq.Init.Logic.rew_ex2".

Dedukti Enable Failproofmode.

Dedukti Enable Verbose.

Load config.

Require Import import.

Dedukti Export All.
