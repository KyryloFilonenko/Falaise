// Mi headers
#include "$1/include/MiEvent.h" 

R__LOAD_LIBRARY($2/lib/libMiModule.so);

void analyze_$4()
{
    int pas_1 = 0;
    int pas_2 = 0;
    int pas_3 = 0;
    int pas_4 = 0;
    int pas_5 = 0;
    int pas_6 = 0;

    int full_N = 0;

    int dirs = $3 + 1;

    for(int d = 0; d < dirs; d++)
    {
        TFile* f = new TFile(Form("./%d/$4_$5.root", d));
    	TTree* s = (TTree*) f->Get("Event");
    
    	MiEvent* Eve = new MiEvent();
    	s->SetBranchAddress("Eventdata", &Eve);
        
        int N = s->GetEntries();
        full_N += N;
        
        int n_calo;
        int n_calov;
        int n_rec = 0;
        int n_neg;
        double energy;
    
    	for(UInt_t i=0; i < N; i++)	// Loop over events
    	{
    		s->GetEntry(i);
            
            n_calo = 0;
            n_calov = 0;
            n_neg = 0;
            energy = 0;
            
            n_rec = Eve->getPTD()->getpartv()->size();
            
            for(int j = 0; j < n_rec; j++)
            {
                n_calo = Eve->getPTD()->getpartv()->at(j).getcalohitv()->size();
                if(Eve->getPTD()->getpartv()->at(j).getcharge() == -1) n_neg++;
                for(int k = 0; k < n_calo; k++)
                {
                    energy += Eve->getPTD()->getpartv()->at(j).getcalohitv()->at(k).getE();
                }
                n_calov += n_calo;
            }
                                            
            if (n_calov == 2) pas_1++;
            if (n_calov == 2 && n_rec == 2) pas_2++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2) pas_3++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2 && energy > 2000.0) pas_4++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2 && energy > 2700.0) pas_5++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2 && energy > 2700.0 && energy < 3300.0) pas_6++;
    	}
    }
    cout << "Num events:" << full_N << endl;
    cout << endl << "EFFICIENCIES :" << endl;
	cout << "eps1 = " << (100.0 * pas_1) / full_N << "% +- " << (100.0 * sqrt(double(pas_1)) ) / full_N << "%" << endl;
	cout << "eps2 = " << (100.0 * pas_2) / full_N << "% +- " << (100.0 * sqrt(double(pas_2)) ) / full_N << "%" << endl;
    cout << "eps3 = " << (100.0 * pas_3) / full_N << "% +- " << (100.0 * sqrt(double(pas_3)) ) / full_N << "%" << endl;
    cout << "eps4 = " << (100.0 * pas_4) / full_N << "% +- " << (100.0 * sqrt(double(pas_4)) ) / full_N << "%" << endl;
    cout << "eps5 = " << (100.0 * pas_5) / full_N << "% +- " << (100.0 * sqrt(double(pas_5)) ) / full_N << "%" << endl;
    cout << "eps6 = " << (100.0 * pas_6) / full_N << "% +- " << (100.0 * sqrt(double(pas_6)) ) / full_N << "%" << endl;
}





