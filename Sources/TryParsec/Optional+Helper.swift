extension Optional
{
    /// Haskell's `maybeToList`.
    internal func toArray() -> [Wrapped]
    {
        return self != nil ? [self!] : []
    }
}
