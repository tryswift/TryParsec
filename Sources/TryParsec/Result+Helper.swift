import Runes

// MARK: Result + applicative style

// See also https://github.com/antitypical/Result/pull/105 (unmerged)

public func <^> <T, U, Error> (transform: (T) -> U, result: Result<T, Error>) -> Result<U, Error>
{
    return result.map(transform)
}

public func <*> <T, U, Error> (transform: Result<(T) -> U, Error>, result: @autoclosure () -> Result<T, Error>) -> Result<U, Error>
{
    return transform.flatMap { f in result().map(f) }
}
