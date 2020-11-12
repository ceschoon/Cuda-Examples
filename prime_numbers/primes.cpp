#include <iostream>

using namespace std;

bool isDivisible(int n, int np, int *primes)
{
	for (int i=0; i<np; i++) 
	{
		int p = primes[i];
		if (n%p==0) return true;
		
		// check we do not test further than sqrt(n)
		if (p*p>n) break;
	}
	
	return false;
}

int main()
{
	int Np = 1<<21;   // number of primes to compute
	int *primes = (int*)malloc(Np*sizeof(int));
	
	int np = 0;      // number of computed primes
	int n = 2;       // current number being tested
	
	while(np<Np)
	{
		// test if n is prime by checking division by previous primes
		if (!isDivisible(n,np,primes))
		{
			primes[np] = n;
			np ++; 
		}
		
		// next number
		n ++;
	}

	for (int i=0; i<Np; i++) cout << primes[i] << endl;
}
