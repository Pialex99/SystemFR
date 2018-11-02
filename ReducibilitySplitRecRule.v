Require Import Equations.Equations.

Require Import Coq.Strings.String.
Require Import Coq.Lists.List.

Require Import Termination.Syntax.
Require Import Termination.Tactics.
Require Import Termination.AssocList.
Require Import Termination.StarRelation.
Require Import Termination.Freshness.
Require Import Termination.SubstitutionLemmas.
Require Import Termination.SmallStep.
Require Import Termination.SmallStepSubstitutions.
Require Import Termination.StarLemmas.
Require Import Termination.StarInversions.
Require Import Termination.Freshness.
Require Import Termination.ListUtils.

Require Import Termination.TermList.
Require Import Termination.TermListLemmas.

Require Import Termination.FVLemmas.
Require Import Termination.FVLemmasTermList.

Require Import Termination.WFLemmas.
Require Import Termination.WFLemmasTermList.

Require Import Termination.Sets.
Require Import Termination.SetLemmas.

Require Import Termination.Equivalence.
Require Import Termination.EquivalenceLemmas.
Require Import Termination.EquivalenceLemmasRec.

Require Import Termination.ReducibilityDefinition.
Require Import Termination.ReducibilityLemmas.
Require Import Termination.RedTactics.


Opaque reducible_values.
Opaque makeFresh.

Lemma equivalent_split_rec:
  forall (gamma1 gamma2 : context) (n t t' e1 e2 e : term) (x y v: nat) l T,
    open_reducible gamma2 n T_nat ->
    (forall z, z ∈ support gamma1 -> z ∈ fv e1 -> False) ->
    (forall z, z ∈ support gamma1 -> z ∈ fv e2 -> False) ->
    (forall z, z ∈ support gamma1 -> z ∈ fv e -> False) ->
    (forall z, z ∈ support gamma1 -> z ∈ fv n -> False) ->
    (forall z, z ∈ support gamma1 -> z ∈ fv T -> False) ->
    ~(x ∈ fv_context gamma1) ->
    ~(x ∈ fv_context gamma2) ->
    ~(x ∈ fv t) ->
    ~(x ∈ fv t') ->
    ~(y ∈ fv e) ->
    ~(y ∈ fv e1) ->
    ~(y ∈ fv e2) ->
    ~(y ∈ fv n) ->
    ~(y ∈ fv t) ->
    ~(y ∈ fv t') ->
    ~(y ∈ fv T) ->
    ~(y ∈ fv_context gamma1) ->
    ~(y ∈ fv_context gamma2) ->
    ~(v ∈ fv e) ->
    ~(v ∈ fv e1) ->
    ~(v ∈ fv e2) ->
    ~(v ∈ fv n) ->
    ~(v ∈ fv t) ->
    ~(v ∈ fv t') ->
    ~(v ∈ fv T) ->
    ~(v ∈ fv_context gamma1) ->
    ~(v ∈ fv_context gamma2) ->
    NoDup (x :: y :: v :: nil) ->
    subset (fv n ++ fv e1 ++ fv e2) (support gamma2) ->
    subset (fv e) (support gamma2) ->
    wf (rec T n e1 e2) 0 ->
    (forall l : list (nat * term),
       satisfies reducible_values (gamma1 ++ (x, T_equal e1 e) :: (y, T_equal n zero) :: gamma2) l ->
       equivalent (substitute t l) (substitute t' l)) ->
    (forall l : list (nat * term),
       satisfies reducible_values
                    (gamma1 ++
                            (x, T_equal
                                   (open 0 (open 1 e2 (fvar v))
                                     (lambda T_unit (rec T (fvar v) e1 e2)))
                                 e)
                            :: (y, T_equal n (succ (fvar v))) :: (v, T_nat) :: gamma2) l ->
          equivalent (substitute t l) (substitute t' l)) ->
    satisfies reducible_values (gamma1 ++ (x, T_equal (rec T n e1 e2) e) :: gamma2) l ->
    equivalent (substitute t l) (substitute t' l).
Proof.
  unfold open_reducible, reducible, reduces_to;
    repeat step || t_listutils || t_sat_cut || tt || tlist || step_inversion satisfies ||
           simp_red.

  destruct t'0; steps.
  
  - unshelve epose proof (H31 (l1 ++ (x,trefl) :: (y,trefl) :: l) _);
      repeat tac1 || step_inversion NoDup;
      eauto 2 using satisfies_drop.
      
  - unshelve epose proof (H32 (l1 ++ (x,trefl) :: (y,trefl) :: (v,t'0) :: l) _); 
      clear H30; 
      repeat tac1 || step_inversion NoDup;
      eauto 2 using satisfies_drop.
Qed.
