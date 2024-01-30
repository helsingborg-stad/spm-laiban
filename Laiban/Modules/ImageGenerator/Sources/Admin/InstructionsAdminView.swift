//
//  InstructionsAdminView.swift
//
//
//  Created by Dan Nilsson on 2024-01-30.
//

import Foundation
import SwiftUI

struct InstructionsAdminView: View {

    var body: some View {
        Section(header: Text("Insekter och geometri som estetiska uttrycksformer").font(.title)) {
            Text("Syftet med att barn instruerar, programmerar och tar hjälp av Laiban för att rita geometriska figurer och undersöka färger är har fler aspekter och lärandemål.")
            Text("För det första, genom att ge instruktioner till en AI (artificiell intelligens), får barnen ett tidigt möte och introduktion till olika digitala tjänster som vi har runt omkring oss till vardags samt får uppleva hur instruktioner och kod styr dem, är en viktig färdighet i dagens digitala värld och en kompensatorisk insats utifrån barns olika livssituationer och socioekonomiska förutsättningar. Därför blir det extra viktigt att pedagogerna möter barnens frågor och hjälper dem att förstå detta innan man sätter igång med att använda tjänsten. Det vill säga, samtalet kring varför vi använder Laiban och andra digitala tjänster är grundläggande för att förstå hur vi ska förhålla oss till att vara omgivna av digitala verktyg till vardags. Här blir pedagogens kompetens och förförståelse ett fundament för hur vi skapar förutsättningar för barnens digitala kompetens.")
            Text("För det andra, genom att använda AI för att rita geometriska figurer, kan barnen utforska och förstå grundläggande matematiska koncept på ett interaktivt och engagerande sätt. De kan lära sig om olika geometriska former, deras egenskaper och hur och var de framträder hos insekter och i naturen. Här kan pedagogen planera för didaktiska inslag i undervisningen där barnen tillåts undersöka och utforska andra miljöer och platser där geometriska figurer kan återfinnas, i skogen till exempel!")
            Text("För det tredje, genom att undersöka färger med AI, kan barnen lära sig om färgteori, hur olika färger kan kombineras för att skapa nya nyanser samt vilka färger som finns naturligt i naturen och vilka färger insekter har – och varför. Här möjliggörs vidare utforskanden och samtal kring naturvetenskapliga fenomen utifrån vilka frågor barnen ställer.")
            Text("Slutligen så är tanken att denna funktion, som genererar dessa unika geometriska insekter, ska initiera en mängd av olika estetiska undervisningsmoment utifrån förskolans tvärvetenskapliga undervisningspraktik. Att hjälpa barnen att gå från det digitala till det analoga och estetiska ger barnen en möjlighet att förstå nyttan med att programmera och kontrollera en AI som ett startskott för andra moment såsom att rita geometriska figurer och undersöka färger.")
            Text("Genom estetiska lärprocesser uppstår nya frågor och reflektioner hos barnen som dels kan generera ett fördjupat kunnande inom ramen för digital kompetens. Inte minst vad gäller att grundlägga förmågor att navigera i en digitaliserad omvärld med kompetenser inom t ex källkritik och programmering, varför pedagogens närvaro, ledning och stimulans blir ytterst viktig. När barnen får utlopp för sin kreativitet och arbeta utifrån sina frågeställningar med händerna och kroppen förstärks lärandet och ett förändrat kunnande sker och öppnar för att grundlägga förändrade förhållningssätt.")
        }
        Section {
            Text("Bakgrund").font(.title)
            Text("Detta undervisningsupplägg handlar framför allt om att grundlägga och förbereda barnen på ett samhälle där barn som vuxna är omgivna av kod och programmerade system och apparater. Det här ska ses som ett material där diskussionen före är kanske viktigare än själva arbetet med insekterna då man i samtalet kan lyfta erfarenheter, tankar och lägga de första bitarna till det som högst troligt blir en avgörande kunskap framöver- AI-litteracitet.")
            Text("Om AI-litteracitet").font(.subheadline)
            Text("Litteracitet är ett begrepp som beskriver en persons förmåga att läsa, skriva och förstå texter. Men det är också en bredare term idag och inkluderar även områden där man behöver ha kunskap för att kunna både förstå, uttrycka sig och kritiskt granska t ex medialitteracitet och digital litteracitet.")
            Text("När det kommer till AI-litteracitet så handlar det om att ha kunskap om artificiell intelligens och autonoma system, samt att kunna kritiskt granska både möjligheter och utmaningar med användningen av dessa teknologier i samhället och i utbildning.")
            Text("Därför kan vi se att just samtalen innan blir så viktiga och säkert avgörande i vissa fall utifrån vad vissa vårdnadshavare tillhandahåller hemma. Med den kompletterande upplevelsen av AI-tjänsten samt de viktiga efterföljande estetiska uttrycken och det matematiska utforskandet kan vi se att användandet av detta digitala verktyg och tjänst uppfyller behoven och kraven på såväl pedagogisk nytta som läroplanens skrivningar av att förstå sin samtid.")
            Text("Varför AI-beredskap i förskola?").font(.subheadline)
            Text("Att grundlägga och skapa metodik för AI-beredskap handlar om barnens rätt att förstå sin samtid och kunna få delaktighet och inflytande. Douglas Rushkoff (mediateoretiker, professor) pratar om att sätta sig i kontroll (transformativ samtid) ”En positiv framtidstro ska prägla utbildningen” (Lpfö) utifrån digital kompetens och AI behöver vi säkerställa att vi ger barnen i förskolan beredskap för det som kommer vara deras framtid. Adekvat digital kompetens blir därför en demokratifråga. Det behöver yttra sig i att designa tillgängliga lärmiljöer där utforskandet av digital kompetens och AI-beredskap blir likvärdigt tillgängligt för alla barn, oavsett funktionsförmåga.")
            Text("Vad säger läroplanen?").font(.subheadline)
            Text("Metodik").font(.subheadline)
            Text("Geometrijakt").font(.subheadline)
            Text("Fantasiinsekter i estetiska lärprocesser").font(.subheadline)
            Text("Dra nytta av flera verktyg").font(.subheadline)
        }
        Section(header: Text("Användarinstruktioner Laiban").font(.headline)) {
            Text("""
            1. Välj en insekt som du vill skapa
            2. Välj vilken geometrisk form du vill att den ska ha
            3. Välj vilken färg du vill att din geometriska insekt ska ha
            4. Generera!
            5. Påbörja en kreativ process utifrån barnets AI-genererade insekt
            """)
        }
        Section(header: Text("Frågor att samtala med barnen kring").font(.headline)) {
            Text("""
            1. Vad är en AI och digital assistent som Laiban?
            2. Vad tror du att en robot kan göra?
            3. Vad är skillnaden mellan en AI och en robot?
            4. Om du hade en robot, vad skulle du lära den att göra då?
            5. Om du kunde bygga och träna en AI, vad skulle du lära den att göra då?
            6. Hur lär du dig saker och hur tränar du på att blir bättre på att t ex läsa eller knyta skorna?
            7. Hur tror ni att Laiban eller en robot lär sig saker?
            8. Vad tänker du är skillnaden mellan människor och robotar?
            9. Vad är en kompis? Kan en AI vara din kompis?
            10. Vilka djur skulle vara bra som robotar tror du?
            11. Hur kan man träna en robot till att få den att göra som man vill?
            """)
        }
    }
}

struct InstructionsAdminView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsAdminView()
    }
}
