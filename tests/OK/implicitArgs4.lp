symbol const U : TYPE
// Mini interpretation function from code of types to real types
symbol injective T : U ⇒ TYPE

definition RodolpheExample (A:U) (B:U) (C:U) (D:U) : T A ⇒ T B ⇒ T C ⇒ (T A ⇒ T B ⇒ T C ⇒ T D) ⇒ T D ≔
  λ(x : T A) (y : T B) (z : T C) (f : ∀(m:T A)(n:T B)(k:T C), T D), f x y z
