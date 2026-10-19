import SwiftUI
import UIKit

/// A tela do LibertyX Folder Pro: o que a rede libera, a situação do teste, comprar pelo
/// Telegram e ativar a chave. Aberta das configurações, ou no lugar de uma tela da rede depois
/// do teste ([ProPortao]).
struct TelaPro: View {

    @ObservedObject private var pro = Pro.shared
    @State private var digitandoChave = false

    static let bot = URL(string: "https://t.me/libertx_partition_bot?start=folder")!

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("Marca").resizable().scaledToFit().frame(width: 84, height: 84).padding(.top, 18)
                HStack(spacing: 8) {
                    Text("LibertyX").font(LxFonte.titulao).foregroundStyle(Lx.texto)
                    Text("PRO")
                        .font(.system(size: 15, weight: .heavy)).kerning(1.5)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 9).padding(.vertical, 3)
                        .background(Lx.ouro, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 14)
                situacao.padding(.top, 12)

                VStack(spacing: 2) {
                    linha("server.rack", "Servidores da rede", "Abra, copie e mova arquivos entre o iPhone e o PC ou servidor.")
                    linha("dot.radiowaves.left.and.right", "Busca automática", "Encontra sozinho os computadores da rede de casa.")
                    linha("play.rectangle", "Vídeo e música da rede", "Tocam direto do servidor, sem baixar antes.")
                }
                .padding(.vertical, 6)
                .vidro()
                .padding(.top, 22)

                Text("Os arquivos do iPhone, as categorias e a pesquisa continuam grátis para sempre.")
                    .font(LxFonte.f(13)).foregroundStyle(Lx.apagado)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)

                if pro.estado != .comprado {
                    Link(destination: Self.bot) {
                        VStack(spacing: 2) {
                            Text("Pagar com Bitcoin ou USDT").font(LxFonte.f(16, .heavy))
                            Text("Pelo Telegram — a chave chega na hora").font(LxFonte.f(12)).opacity(0.7)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Lx.ouro, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 24)
                    Text("Pagamento único, sem assinatura. A mesma chave vale no iPhone, no Android e na TV.")
                        .font(LxFonte.f(12)).foregroundStyle(Lx.tenue)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    Button("Tenho uma chave") { digitandoChave = true }
                        .font(LxFonte.f(14, .semibold)).foregroundStyle(Lx.apagado)
                        .padding(.vertical, 12)
                } else if let id = pro.licenca {
                    Text("Licença \(id)").font(LxFonte.f(12)).foregroundStyle(Lx.tenue).padding(.top, 20)
                }
            }
            .frame(maxWidth: 520)
            .padding(.horizontal, 22)
            .padding(.bottom, 60)
            .frame(maxWidth: .infinity)
        }
        .background(BrilhoDeFundo())
        .navigationTitle("LibertyX Pro")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { pro.recalcular() }
        .sheet(isPresented: $digitandoChave) { TelaDaChave() }
    }

    @ViewBuilder private var situacao: some View {
        let (texto, cor): (String, Color) = {
            switch pro.estado {
            case .comprado: return (String(localized: "Pro ativo — obrigado!"), Lx.verde)
            case .teste(let dias): return (String(localized: "Teste grátis: \(dias) dias restantes"), Lx.ouro)
            case .expirado: return (String(localized: "Seu teste grátis terminou"), Lx.apagado)
            }
        }()
        HStack(spacing: 6) {
            if pro.estado == .comprado { Image(systemName: "checkmark.circle.fill").font(.system(size: 15)) }
            Text(texto).font(LxFonte.f(13, .bold))
        }
        .foregroundStyle(cor)
        .padding(.horizontal, 14).padding(.vertical, 7)
        .background(cor.opacity(0.13), in: Capsule())
        .overlay(Capsule().strokeBorder(cor.opacity(0.45), lineWidth: 0.5))
    }

    private func linha(_ simbolo: String, _ titulo: LocalizedStringKey, _ texto: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            Image(systemName: simbolo)
                .font(.system(size: 19, weight: .semibold)).foregroundStyle(Lx.ouro)
                .frame(width: 40, height: 40)
                .background(Lx.ouro.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).font(LxFonte.f(15, .bold)).foregroundStyle(Lx.texto)
                Text(texto).font(LxFonte.f(13)).foregroundStyle(Lx.apagado)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .padding(.horizontal, 6)
    }
}

/// Colar a chave que o bot mandou no Telegram.
struct TelaDaChave: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var pro = Pro.shared
    @State private var texto = ""
    @State private var erro: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if pro.estado == .comprado {
                        Label("Pro ativado com a sua chave — obrigado!", systemImage: "checkmark.circle.fill")
                            .font(LxFonte.f(17, .bold)).foregroundStyle(Lx.verde)
                            .padding(.top, 20)
                        if let id = pro.licenca {
                            Text("Licença \(id)").font(LxFonte.f(12)).foregroundStyle(Lx.tenue)
                        }
                    } else {
                        Text("Cole a chave que o bot da LibertyX mandou no Telegram. Ela começa com LXP1.")
                            .font(LxFonte.f(14)).foregroundStyle(Lx.apagado)
                        TextEditor(text: $texto)
                            .font(.system(size: 14, design: .monospaced))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .frame(minHeight: 110)
                            .vidro(14)
                            .onChange(of: texto) { erro = nil }
                        if let erro {
                            Text(erro).font(LxFonte.f(13)).foregroundStyle(Lx.vermelho)
                        }
                        HStack(spacing: 10) {
                            Button {
                                if let colado = UIPasteboard.general.string { texto = colado.trimmingCharacters(in: .whitespacesAndNewlines) }
                            } label: {
                                Text("Colar").font(LxFonte.f(16, .bold)).foregroundStyle(Lx.texto)
                                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                                    .vidro(16)
                            }
                            Button {
                                if case .recusada(let e) = pro.ativar(texto) { erro = Self.mensagem(e) }
                            } label: {
                                Text("Ativar").font(LxFonte.f(16, .heavy)).foregroundStyle(.black)
                                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                                    .background(Lx.ouro, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        Link("Ainda não tem chave? Compre pelo Telegram", destination: TelaPro.bot)
                            .font(LxFonte.f(14, .semibold)).foregroundStyle(Lx.apagado)
                            .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .background(Lx.fundo.ignoresSafeArea())
            .navigationTitle("Ativar com uma chave")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Concluído") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    static func mensagem(_ e: Chave.Erro) -> String {
        switch e {
        case .formato: return String(localized: "Isso não parece uma chave completa. Copie de novo no Telegram e cole inteira.")
        case .invalida: return String(localized: "Esta chave não é válida. Confira se copiou ela toda.")
        case .outroApp: return String(localized: "Esta chave é de outro app LibertyX, não do Folder.")
        case .versao: return String(localized: "Esta chave é de uma versão mais nova. Atualize o app e tente de novo.")
        }
    }
}

/// No lugar de uma tela da rede: a tela quando o Pro está ativo, a do Pro quando não — e troca
/// sozinho quando a chave é ativada.
struct ProPortao<Conteudo: View>: View {
    @ViewBuilder var conteudo: () -> Conteudo
    @ObservedObject private var pro = Pro.shared

    var body: some View {
        if pro.ativo { conteudo() } else { TelaPro() }
    }
}
