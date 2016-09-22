extension RangeReplaceableCollection
{
    /// Missing initializer.
    public init(_ x: Self.Iterator.Element)
    {
        self.init()
        self.append(x)
    }
}
