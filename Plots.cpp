#include <TCanvas.h>
#include <TGraphErrors.h>
#include <TAxis.h>
#include <TLegend.h>
#include <TLatex.h>

void Plots() {
    double x[] = {1, 2, 3, 4, 5, 6};
    double y_flat[] = {48.523, 32.122, 23.185, 22.291, 13.090, 12.734};
    double y_flat_err[] = {0.022, 0.018, 0.015, 0.015, 0.011, 0.011};

    double y_bent[] = {47.662, 31.048, 23.338, 22.355, 13.199, 12.844};
    double y_bent_err[] = {0.022, 0.018, 0.015, 0.015, 0.012, 0.011};

    int n_points = 6;

    // Помножуємо похибки на 10
    for (int i = 0; i < n_points; i++) {
        y_flat_err[i] *= 50;
        y_bent_err[i] *= 50;
    }

    TGraphErrors *graph_flat = new TGraphErrors(n_points, x, y_flat, 0, y_flat_err);
    TGraphErrors *graph_bent = new TGraphErrors(n_points, x, y_bent, 0, y_bent_err);

    graph_flat->SetMarkerStyle(20); // Кружечки
    graph_flat->SetMarkerColor(kBlue);
    graph_flat->SetLineColor(kBlue);

    graph_bent->SetMarkerStyle(20); // Кружечки
    graph_bent->SetMarkerColor(kRed);
    graph_bent->SetLineColor(kRed);

    TCanvas *c1 = new TCanvas("c1", "Graph with Errors", 800, 600);

    graph_flat->GetXaxis()->SetTitle("Epsilon");
    graph_flat->GetYaxis()->SetTitle("Values");
    graph_flat->GetXaxis()->SetLimits(0.5, 6.5);

    graph_flat->Draw("AP");
    graph_bent->Draw("P SAME");

    TLegend *legend = new TLegend(0.7, 0.7, 0.9, 0.9);
    legend->AddEntry(graph_flat, "Flat", "p");
    legend->AddEntry(graph_bent, "Bent", "p");
    legend->Draw();

    // Підписи осі X за допомогою TLatex
    TLatex latex;
    latex.SetTextSize(0.035);
    latex.SetTextAlign(22); // Вирівнювання по центру
    for (int i = 0; i < n_points; i++) {
        latex.DrawLatex(x[i], graph_flat->GetXaxis()->GetBinLowEdge(0) - 5, Form("#varepsilon_{%d}", i + 1));
    }

    c1->SaveAs("graph_with_errors_updated.png");
}
