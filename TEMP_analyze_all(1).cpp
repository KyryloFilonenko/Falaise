// Mi headers
#include "$1/include/MiEvent.h" 

R__LOAD_LIBRARY($2/lib/libMiModule.so);

void analyze_$5()
{
    const int num_simu = $6; 
    string simu_data[num_simu] = {$7};
    
    for(int s = 0; s < num_simu; s++)
    {
        int pas_1 = 0;
        int pas_2 = 0;
        int pas_3 = 0;
        int pas_4 = 0;
        int pas_5 = 0;
        int pas_6 = 0;
    
        int full_N = 0;
    
        for(int d = 0; d <= $3; d++)
        {
            string file_path = Form("./%s/%d/%s_$4.root", simu_data[s].c_str(), d, simu_data[s].c_str());
            
            if (gSystem->AccessPathName(file_path.c_str())) {
                cout << "File not found in folder: " << d << endl;
                continue;
            }

            TFile* f = new TFile(file_path.c_str());
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
        cout << endl;
        cout << "*********************************************" << endl;
        cout << "Simu name: " << simu_data[s].c_str() << endl;
        cout << "Num events: " << full_N << endl;
        cout << endl << "EFFICIENCIES :" << endl;
    	cout << "eps1 = " << (100.0 * pas_1) / full_N << "% +- " << (100.0 * sqrt(double(pas_1)) ) / full_N << "%" << endl;
    	cout << "eps2 = " << (100.0 * pas_2) / full_N << "% +- " << (100.0 * sqrt(double(pas_2)) ) / full_N << "%" << endl;
        cout << "eps3 = " << (100.0 * pas_3) / full_N << "% +- " << (100.0 * sqrt(double(pas_3)) ) / full_N << "%" << endl;
        cout << "eps4 = " << (100.0 * pas_4) / full_N << "% +- " << (100.0 * sqrt(double(pas_4)) ) / full_N << "%" << endl;
        cout << "eps5 = " << (100.0 * pas_5) / full_N << "% +- " << (100.0 * sqrt(double(pas_5)) ) / full_N << "%" << endl;
        cout << "eps6 = " << (100.0 * pas_6) / full_N << "% +- " << (100.0 * sqrt(double(pas_6)) ) / full_N << "%" << endl;
        cout << "*********************************************" << endl;
        cout << endl;
    }
}





