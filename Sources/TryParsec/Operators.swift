// Keep custom-operator precedences as best we can.
// - https://github.com/thoughtbot/Runes
// - https://github.com/typelift/Operadics

/// Haskell `infixl 1`.
infix operator >>-  { associativity left precedence 100 }

/// Haskell `infixl 3` (Haskell.Parsec `infixr 1 <|>`).
/// - Note: typelift/Operadics use `precedence 120` for `infixr 2` and `precedence 130` for `infixl 4`.
infix operator <|>  { associativity left precedence 125 }

// Comment-Out: `associativity right` is not preferred (but interestingly, performance is slightly faster)
//infix operator <|>  { associativity right precedence 100 }

/// Haskell `infixl 4`.
infix operator <*>  { associativity left precedence 130 }

/// Haskell `infixl 4`.
infix operator <*   { associativity left precedence 140 }

/// Haskell `infixl 4`.
infix operator *>   { associativity left precedence 140 }

/// Haskell `infixl 4`.
infix operator <^>  { associativity left precedence 130 }
infix operator <&>  { associativity left precedence 130 }

/// Haskell.Parsec/Attoparsec `infix 0`.
infix operator <?>  { associativity none precedence 0 }
