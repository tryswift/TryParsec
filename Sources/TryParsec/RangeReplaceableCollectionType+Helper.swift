extension RangeReplaceableCollectionType
{
    /// Missing initializer.
    public init(_ x: Self.Generator.Element)
    {
        self.init()
        self.append(x)
    }
}
