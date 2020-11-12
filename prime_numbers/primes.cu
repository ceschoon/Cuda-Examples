#include <stdio.h>


__global__
void areDivisible(int n, int Nb, int np, int *knownprimes, bool *ans)
{
	int i = blockIdx.x*blockDim.x + threadIdx.x; // between [0 and Nb[
	int ni = n+i;  // number to be tested
	
	if (i<Nb)
	{
		ans[i] = false;
		for (int j=0; j<np; j++) 
		{
			int p = knownprimes[j];
			if (ni%p==0) ans[i] = true;
			
			// check we do not test further than sqrt(ni)
			if (p*p>ni) break;
		}
	}
}


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


int main(void)
{
	int Np = 1<<21;   // number of primes to compute
	int Nb = 1<<17;    // batch size of numbers tested at once on gpu
	
	int *primes, *d_primes;
	bool *ans, *d_ans;
	primes = (int*) malloc(Np*sizeof(int));
	ans = (bool*) malloc(Nb*sizeof(bool));
	cudaMalloc(&d_primes, Np*sizeof(int));
	cudaMalloc(&d_ans, Nb*sizeof(bool));
	
	// init
	int n=2;
	int np=0;
	
	// serial search for primes between 0 and Nb
	while(n<Nb)
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
	
	// parallel search for remaining primes
	while(np<Np)
	{
		// run divisibility tests on the batch from [n to n+Nb[
		cudaMemcpy(d_primes, primes, np*sizeof(int), cudaMemcpyHostToDevice);
		areDivisible<<<(Nb+255)/256, 256>>>(n, Nb, np, d_primes, d_ans);
		cudaMemcpy(ans, d_ans, Nb*sizeof(bool), cudaMemcpyDeviceToHost);
		
		// analyse results
		for (int i=0; i<Nb; i++) if (!ans[i] && np<Np)
		{
			primes[np] = n+i;
			np ++;
		}
		
		// increment
		n += Nb;
	}
	
	for (int i=0; i<Np; i++) printf("%d\n", primes[i]);
	
	cudaFree(d_primes);
	cudaFree(d_ans);
	free(primes);
	free(ans);
}
