Require Import Equations.Equations.

Require Import Coq.Arith.PeanoNat.
Require Import Coq.Lists.List.
Require Import Coq.Strings.String.

Require Import SystemFR.Syntax.
Require Import SystemFR.Tactics.
Require Import SystemFR.TermProperties.
Require Import SystemFR.Sets.
Require Import SystemFR.TermList.
Require Import SystemFR.ListUtils.
Require Import SystemFR.AssocList.
Require Import SystemFR.Freshness.
Require Import SystemFR.SmallStep.
Require Import SystemFR.SubstitutionLemmas.
Require Import SystemFR.StarLemmas.
Require Import SystemFR.StarInversions.
Require Import SystemFR.SmallStepSubstitutions.
Require Import SystemFR.SetLemmas.
Require Import SystemFR.StarRelation.

Require Import SystemFR.Equivalence.
Require Import SystemFR.EquivalenceLemmas.

Require Import SystemFR.FVLemmas.
Require Import SystemFR.FVLemmasLists.


Require Import SystemFR.WFLemmas.
Require Import SystemFR.WFLemmasLists.

Require Import SystemFR.ReducibilityCandidate.
Require Import SystemFR.ReducibilityDefinition.
Require Import SystemFR.ReducibilityLemmas.
Require Import SystemFR.ReducibilityLetRules.
Require Import SystemFR.ReducibilityLetTermRules.
Require Import SystemFR.RedTactics.

Opaque reducible_values.
Opaque makeFresh.

Lemma reducible_type_refine:
  forall theta t1 t2 A B,
    valid_interpretation theta ->
    reducible theta t1 A ->
    reducible theta t2 (T_let t1 B) ->
    reducible theta t1 (T_type_refine A B).
Proof.
  unfold reducible, reduces_to in *; repeat step;
    eauto with bwf; eauto with bfv.

  eexists; steps; eauto.
  repeat step || simp_red || t_deterministic_star; t_closer.
Qed.

Lemma open_reducible_type_refine:
  forall tvars gamma t1 t2 A B,
    open_reducible tvars gamma t1 A ->
    open_reducible tvars gamma t2 (T_let t1 B) ->
    open_reducible tvars gamma t1 (T_type_refine A B).
Proof.
  unfold open_reducible; repeat step || t_instantiate_sat3;
    eauto using reducible_type_refine.
Qed.

Lemma open_reducible_get_refinement_witness:
  forall tvars gamma t1 t2 A B T x,
    ~(x ∈ tvars) ->
    ~(x ∈ fv_context gamma) ->
    ~(x ∈ fv t1) ->
    ~(x ∈ fv t2) ->
    ~(x ∈ fv T) ->
    ~(x ∈ fv A) ->
    ~(x ∈ fv B) ->
    wf t1 0 ->
    wf t2 0 ->
    is_erased_term t2 ->
    subset (fv t1) (support gamma) ->
    subset (fv t2) (support gamma) ->
    open_reducible tvars gamma t1 (T_type_refine A B) ->
    open_reducible tvars ((x, T_let t1 B) :: gamma) t2 T ->
    open_reducible tvars gamma (app (notype_lambda t2) uu) T.
Proof.
  unfold open_reducible; repeat step || t_instantiate_sat3.
  eapply backstep_reducible; eauto with smallstep values;
    repeat step || t_listutils; eauto with bfv bwf berased.
  rewrite open_none; eauto with bwf.
  top_level_unfold; repeat step || simp_red.

  unshelve epose proof (H12 theta ((x, p) :: lterms) _ _ _); tac1.
  exists t'; steps; eauto with berased; eauto using red_is_val.
Qed.
