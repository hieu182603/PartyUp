abstract interface class IMapper<TSource,TDestination> {
  TDestination map(TSource source);
}