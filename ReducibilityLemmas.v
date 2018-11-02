Require Import Equations.Equations.

Require Import Termination.ReducibilityDefinition.
Require Import Termination.Tactics.
Require Import Termination.Syntax.
Require Import Termination.SmallStep.
Require Import Termination.TermProperties.
Require Import Termination.SizeLemmas.
Require Import Termination.SubstitutionLemmas.
Require Import Termination.SmallStepIrredLemmas.
Require Import Termination.TermList.
Require Import Termination.ReducibilityDefinition.
Require Import Termination.ListUtils.
Require Import Termination.SizeLemmas.
Require Import Termination.WFLemmasEval.
Require Import Termination.FVLemmasEval.
Require Import Termination.SmallStepSubstitutions.
Require Import Termination.StarLemmas.
Require Import Termination.StarInversions.
Require Import Termination.TypeForm.

Require Import Omega.

Opaque reducible_values. (* workaround for rewriting speed *)

Lemma reducible_val_fv_aux:
  forall n T t,
    size T < n ->
    reducible_values t T ->
    fv t = nil.
Proof.
  induction n; destruct T;
    repeat step || t_listutils || simp reducible_values in *;
    eauto with bfv;
    eauto with omega;
    try solve [ eapply IHn; eauto; omega ];
    try solve [ eapply IHn; eauto; repeat step || autorewrite with bsize in *; omega ].
Qed.

Lemma reducible_val_fv:
  forall T t,
    reducible_values t T ->
    fv t = nil.
Proof.
  eauto using reducible_val_fv_aux.
Qed.

Hint Resolve reducible_val_fv: bfv.

Lemma reducible_val_wf_aux:
  forall n T t,
    size T < n ->
    reducible_values t T ->
    wf t 0.
Proof.
  induction n; destruct T;
    repeat step || t_listutils || simp reducible_values in *;
    eauto with bwf;
    eauto with omega;
    try solve [ eapply IHn; eauto; omega ];
    try solve [ eapply IHn; eauto; repeat step || autorewrite with bsize in *; omega ].
Qed.

Lemma reducible_val_wf:
  forall T t,
    reducible_values t T ->
    wf t 0.
Proof.
  eauto using reducible_val_wf_aux.
Qed.

Hint Resolve reducible_val_wf: bwf.

Lemma red_is_val_aux:
  forall n T v,
    size T < n ->
    reducible_values v T ->
    is_value v.
Proof.
  unfold normalizing; induction n; destruct T;
    repeat step || tlist || t_listutils || simp reducible_values in *;
    eauto with values smallstep;
    eauto with omega;
    try solve [ eapply IHn; eauto; omega ];
    try solve [ eapply IHn; eauto; repeat step || autorewrite with bsize in *; omega ];
    try solve [  apply IVPair; eapply_any; eauto; repeat step || autorewrite with bsize in *; omega].
Qed.

Lemma red_is_val:
  forall T v,
    reducible_values v T ->
    is_value v.
Proof.
  eauto using red_is_val_aux.
Qed.

Hint Immediate red_is_val: values.

Lemma red_irred:
  forall T v,
    reducible_values v T ->
    irred v.
Proof.
  eauto using red_is_val, value_irred.
Qed.
  
Lemma reducible_normalizing:
  forall T e,
    reducible e T ->
    normalizing e.
Proof.
  unfold reducible, reduces_to, normalizing; induction T; steps; eauto using red_is_val.
Qed.
  
Ltac t_transport2 :=
  match goal with
  | H: reducible ?t ?T |- _ =>
    poseNew (Mark H "transport_self");
    pose proof (reducible_normalizing _ _ H)
  end.

Hint Extern 50 => t_transport2: breducible.
Hint Extern 50 => eapply satisfies_lookup: breducible.
Hint Extern 50 => eapply reducible_normalizing: breducible.
Hint Resolve SatCons: breducible.


Ltac t_red :=
  match goal with
         | _ => t_deterministic_step || step
         | _ => progress (simp reducible in *)
         | H1: small_step ?t1 _,
           H2: star small_step ?t1 _ |- _ => inversion H2; clear H2
         | _ => progress (autounfold with props in *)
         | _ => progress (autorewrite with bsize in *)
         | _ => progress (autorewrite with bsem in *)
         end.

Ltac t_reduction :=
  repeat
    t_red ||
    unshelve eauto 3 with smallstep;
      try omega;
      eauto 2 with bwf;
      eauto 2 with bfv.

Ltac t_red_irred :=
  match goal with
  | H1: star small_step ?t ?t1,
    H2: star small_step ?t ?t2,
    H3: irred ?t1 |- _ =>
    poseNew (Mark (t1,t2) "equality");
    unshelve epose proof (star_smallstep_irred2 _ _ H1 _ H2 H3 _)
  end.

Ltac t_values_info2 :=
  match goal with
  | H: reducible_values ?t ?T |- _ =>
    poseNew (Mark t "reducible_value_value");
    pose proof (red_is_val _ _ H)
  end.

Lemma smallstep_norm:
  forall t,
    normalizing t ->
    forall t',
      small_step t t' ->
      normalizing t'.
Proof.
  t_reduction.
Qed.

Hint Resolve smallstep_norm: heavy_red.

Hint Extern 50 => t_reduction: p_tr_lemmas.

Lemma smallstep_reducible_aux:
  forall n T t,
    size T < n ->
    reducible t T ->
    forall t',
      small_step t t' ->
      reducible t' T.
Proof.
  unfold reducible; unfold reduces_to;
    steps;
    eauto 2 with bwf;
    eauto 2 with bfv.

  repeat match goal with
         | H: star small_step _ ?t |- _ => exists t
         | H1: star small_step ?t _, H2: small_step ?t _ |- _ =>
            poseNew (Mark 0 "inversion");
            inversion H1
         | H1: reducible_values ?v _,
           H2: small_step ?v ?t |- _ =>
              apply False_ind; apply evaluate_step with v t; eauto 2 with values
         | _ => step || t_deterministic_step
         end; eauto using red_is_val.
Qed.  

Lemma smallstep_reducible:
  forall T t t',
    small_step t t' ->
    reducible t T ->
    reducible t' T.
Proof.
  eauto using smallstep_reducible_aux. 
Qed.  

Lemma star_smallstep_reducible:
  forall t t',
    star small_step t t' ->
    forall T,
      reducible t T ->
      reducible t' T.
Proof.
  induction 1; steps; eauto using smallstep_reducible.
Qed.  

Lemma backstep_reducible_aux:
  forall n T t',
    size T < n ->
    reducible t' T ->
    forall t,
      fv t = nil ->
      wf t 0 ->
      small_step t t' ->
      reducible t T.
Proof.
  unfold reducible; unfold reduces_to; steps; eauto with smallstep.  
Qed.  

Lemma backstep_reducible:
  forall T t t',
    small_step t t' ->
    fv t = nil ->
    wf t 0 -> 
    reducible t' T ->
    reducible t T.
Proof.
  eauto using backstep_reducible_aux. 
Qed.  

Lemma star_backstep_reducible:
  forall t t',
    star small_step t t' ->
    fv t = nil ->
    wf t 0 ->
    forall T,
      reducible t' T ->
      reducible t T.
Proof.
  induction 1; steps; eauto using backstep_reducible with bfv bwf.
Qed.

Hint Resolve smallstep_reducible: heavy_red.
Hint Resolve backstep_reducible: heavy_red.
Hint Resolve star_smallstep_reducible: heavy_red.
Hint Resolve star_backstep_reducible: heavy_red.

Lemma reducible_values_exprs:
  forall T T' t,
    (forall t, reducible_values t T -> reducible_values t T') ->
    reducible t T ->
    reducible t T'.
Proof.  
  unfold reducible, reduces_to; steps; eauto.
Qed.

Ltac use_red_ind :=
  match goal with
  | H1: forall T v t t', _,
    H2: small_step ?t1 ?t2 |- reducible_values ?v (open 0 ?T ?t1) =>
      unshelve epose proof (H1 T v t1 t2  _ _ _)
  | H1: forall T v t t', _,
    H2: small_step ?t1 ?t2 |- reducible_values ?v (open 0 ?T ?t2) =>
      unshelve epose proof (H1 T v t1 t2  _ _ _)
  end.

Ltac guess_red :=
  match goal with
  | H: star small_step ?t1 ?t2 |- exists t, star small_step ?t1 t /\ _ =>
    exists t2
  end.


Lemma reducible_values_list:
  forall l gamma,
    satisfies reducible_values gamma l ->
    are_values l.
Proof.
  induction l; repeat step || step_inversion satisfies; eauto using red_is_val.
Qed.

Hint Resolve reducible_values_list: values.

Lemma reducible_expr_value:
  forall v T,
    is_value v ->
    reducible v T ->
    reducible_values v T.
Proof.
  unfold reducible, reduces_to; repeat step || t_invert_star.
Qed.

Lemma reducible_values_wf:
  forall l gamma,
    satisfies reducible_values gamma l ->
    wfs l 0.
Proof.
  induction l; repeat step || step_inversion satisfies; eauto using red_is_val.
Qed.

Lemma reducible_wf:
  forall t T, reducible t T -> wf t 0.
Proof.
  unfold reducible, reduces_to; steps.
Qed.

Hint Resolve reducible_wf: bwf.

Lemma reducible_fv:
  forall t T, reducible t T -> fv t = nil.
Proof.
  unfold reducible, reduces_to; steps.
Qed.

Hint Resolve reducible_fv: bfv.

Lemma reducible_value_expr:
  forall t T,
    reducible_values t T ->
    reducible t T.
Proof.
  unfold reducible, reduces_to; steps;
    eauto with bwf;
    eauto with bfv;
    eauto with smallstep.
Qed.

Ltac t_values_info3 :=
  match goal with
  | H: is_value ?v, H2: satisfies _ _ ?l |- _ =>
    is_var v; 
    poseNew (Mark (v,l) "is_value_subst");
    unshelve epose proof (is_value_subst _ H l _); eauto 2 using reducible_values_list
  end.


Lemma value_term_form:
  forall v, is_value v -> term_form v.
Proof.
  inversion 1; steps.
Qed.

Lemma reducible_term_form:
  forall v T, reducible_values v T -> term_form v.
Proof.
  eauto using value_term_form, red_is_val.
Qed.

Hint Resolve value_term_form: btf.
Hint Resolve reducible_term_form: btf.
