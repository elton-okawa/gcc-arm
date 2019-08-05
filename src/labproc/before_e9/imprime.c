main() {
     imprime(5);
}

imprime(N) {
  if (N<0) {
      exit(0);
  }
  printf("numero = %d\n", N);
  imprime(N-1);
}
