//
//  InstructionsAdminView.swift
//
//
//  Created by Dan Nilsson on 2024-01-30.
//

import Foundation
import SwiftUI


struct InstructionsAdminView: View {
    struct Header: View {
        let value: String
        var font: Font = .title
        var body: some View {
            Text(value)
                .font(font)
                .padding(.top, 14)
                .padding(.bottom, -12)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Lärarhandledning")) {
                VStack(alignment: .leading, spacing: 26) {
                    Image("Header", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Header(value: "Insekter och geometri som estetiska uttrycksformer", font: .largeTitle)
                    Text("""
                    Syftet med att barn instruerar, programmerar och tar hjälp av Laiban för att rita geometriska figurer och undersöka färger är har fler aspekter och lärandemål.
                    """)
                    Text("""
                    För det första, genom att ge instruktioner till en AI (artificiell intelligens), får barnen ett tidigt möte och introduktion till olika digitala tjänster som vi har runt omkring oss till vardags samt får uppleva hur instruktioner och kod styr dem, är en viktig färdighet i dagens digitala värld och en kompensatorisk insats utifrån barns olika livssituationer och socioekonomiska förutsättningar. Därför blir det extra viktigt att pedagogerna möter barnens frågor och hjälper dem att förstå detta innan man sätter igång med att använda tjänsten. Det vill säga, samtalet kring varför vi använder Laiban och andra digitala tjänster är grundläggande för att förstå hur vi ska förhålla oss till att vara omgivna av digitala verktyg till vardags. Här blir pedagogens kompetens och förförståelse ett fundament för hur vi skapar förutsättningar för barnens digitala kompetens.
                    """)
                    Text("""
                    För det andra, genom att använda AI för att rita geometriska figurer, kan barnen utforska och förstå grundläggande matematiska koncept på ett interaktivt och engagerande sätt. De kan lära sig om olika geometriska former, deras egenskaper och hur och var de framträder hos insekter och i naturen. Här kan pedagogen planera för didaktiska inslag i undervisningen där barnen tillåts undersöka och utforska andra miljöer och platser där geometriska figurer kan återfinnas, i skogen till exempel!
                    """)
                    Text("""
                    För det tredje, genom att undersöka färger med AI, kan barnen lära sig om färgteori, hur olika färger kan kombineras för att skapa nya nyanser samt vilka färger som finns naturligt i naturen och vilka färger insekter har – och varför. Här möjliggörs vidare utforskanden och samtal kring naturvetenskapliga fenomen utifrån vilka frågor barnen ställer.
                    """)
                    Image("help_shapes", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text("""
                    Slutligen så är tanken att denna funktion, som genererar dessa unika geometriska insekter, ska initiera en mängd av olika estetiska undervisningsmoment utifrån förskolans tvärvetenskapliga undervisningspraktik.  Att hjälpa barnen att gå från det digitala till det analoga och estetiska ger barnen en möjlighet att förstå nyttan med att programmera och kontrollera en AI som ett startskott för andra moment såsom att rita geometriska figurer och undersöka färger.
                    """)
                    Text("""
                    Genom estetiska lärprocesser uppstår nya frågor och reflektioner hos barnen som dels kan generera ett fördjupat kunnande inom ramen för digital kompetens. Inte minst vad gäller att grundlägga förmågor att navigera i en digitaliserad omvärld med kompetenser inom t ex källkritik och programmering, varför pedagogens närvaro, ledning och stimulans blir ytterst viktig. När barnen får utlopp för sin kreativitet och arbeta utifrån sina frågeställningar med händerna och kroppen förstärks lärandet och ett förändrat kunnande sker och öppnar för att grundlägga förändrade förhållningssätt.
                    """)
                    Header(value: "Bakgrund")
                    Text("""
                    Detta undervisningsupplägg handlar framför allt om att grundlägga och förbereda barnen på ett samhälle där barn som vuxna är omgivna av kod och programmerade system och apparater. Det här ska ses som ett material där diskussionen före är kanske viktigare än själva arbetet med insekterna då man i samtalet kan lyfta erfarenheter, tankar och lägga de första bitarna till det som högst troligt blir en avgörande kunskap framöver - AI-litteracitet.
                    """)
                    Header(value: "Om AI-litteracitet")
                    Text("""
                    Litteracitet är ett begrepp som beskriver en persons förmåga att läsa, skriva och förstå texter. Men det är också en bredare term idag och inkluderar även områden där man behöver ha kunskap för att kunna både förstå, uttrycka sig och kritiskt granska t ex medialitteracitet och digital litteracitet.
                    """)
                    Text("""
                    När det kommer till AI-litteracitet så handlar det om att ha kunskap om artificiell intelligens och autonoma system, samt att kunna kritiskt granska både möjligheter och utmaningar med användningen av dessa teknologier i samhället och i utbildning.
                    """)
                    Text("""
                    Därför kan vi se att just samtalen innan blir så viktiga och säkert avgörande i vissa fall utifrån vad vissa vårdnadshavare tillhandahåller hemma. Med den kompletterande upplevelsen av AI-tjänsten samt de viktiga efterföljande estetiska uttrycken och det matematiska utforskandet kan vi se att användandet av detta digitala verktyg och tjänst uppfyller behoven och kraven på såväl pedagogisk nytta som läroplanens skrivningar av att förstå sin samtid.
                    """)
                    Header(value: "Varför AI-beredskap i förskola?")
                    Text("""
                    Att grundlägga och skapa metodik för AI-beredskap handlar om barnens rätt att förstå sin samtid och kunna få delaktighet och inflytande. Douglas Rushkoff (mediateoretiker, professor) pratar om att sätta sig i kontroll (transformativ samtid) ”En positiv framtidstro ska prägla utbildningen” (Lpfö) utifrån digital kompetens och AI behöver vi säkerställa att vi ger barnen i förskolan beredskap för det som kommer vara deras framtid. Adekvat digital kompetens blir därför en demokratifråga.
                    """)
                    Text("""
                    Det behöver yttra sig i att designa tillgängliga lärmiljöer där utforskandet av digital kompetens och AI-beredskap blir likvärdigt tillgängligt för alla barn, oavsett funktionsförmåga.
                    """)
                    Header(value: "Vad säger läroplanen?")
                    Text("""
                    Utifrån läroplanens skrivningar kan man läsa följande:
                    • Utbildningen i förskolan ska bidra till att barnet utvecklar en förståelse för sig själv och sin omvärld.
                    • Förskolan ska aktivt och medvetet påverka och stimulera barnen att efterhand omfatta vårt samhälles gemensamma värderingar och låta dem komma till uttryck i praktisk vardaglig handling i olika sammanhang.
                    """)
                    Text("""
                    Kommentar: Hur ser samhällets värderingar ut i en tid av digitala assistenter och hur grundlägger vi en analytisk förmåga hos barnen vad gäller kunskapsinhämtning respektive relationsbygge? Hur ställer vi oss till ett samhälle där empatiska relationer byggs med robotar och AI? Det är viktigt att man som pedagog är nyfiken på den här typen av diskurser för att vidmakthålla syftet med att arbeta med AI-beredskap. Didaktiken behöver planeras och utformas utifrån syftet med undersökandet, men alltid utifrån barnens frågor och intressen.
                    """)
                    Text("""
                    • Barnen ska ges förutsättningar för bildning, tänkande och kunskapsutveckling utifrån olika aspekter såsom intellektuella, språkliga, etiska, praktiska, sinnliga och estetiska.
                    """)
                    Text("""
                    Det sinneliga utforskandet där barnen lär och upptäcker genom upplevandet och förundran behöver få ta plats för att ge utrymme för nya frågeställningar och ett utbyte av tankar, problem, teorier och lösningar barnen emellan.
                    """)
                    Text("""
                    • förmåga att upptäcka, reflektera över och ta ställning till etiska dilemman och livsfrågor i vardagen
                    • förmåga att använda och förstå begrepp, se samband och upptäcka nya sätt att förstå sin omvärld
                    • utmanas och stimuleras i sin utveckling av språk och kommunikation samt matematik, naturvetenskap och teknik
                    """)
                    Text("""
                    Hållbarhetsperspektivet; barnens positiva framtidstro och handlingskraft och tillgängligheten till olika estetiska material och uttrycksformer för att ge uttryck för innovation, tankar, frågor och idéer. Lära genom lust, nyfikenhet och lek. Ge plats åt sagan och berättandet. Fantasi och lekfullhet i samspel med andra (texten ska utvecklas)
                    """)
                    Header(value: "Metodik")
                    Text("""
                    Geometriska former finns överallt; inomhus, utomhus, på kroppen, på alla saker som vi ser med mera. Geometri är den matematiska principen där man bland annat studerar rumsliga förhållanden och samband mellan olika former. Ett enkelt sätt att utforska geometriska former tillsammans med barn är som i detta exempel med Geometrijakten, är att presentera några av de mest vanligt förekommande och grundläggande geometriska formerna. Låt barnen leta efter dessa former på olika ställen, och gärna med mallen som finns att ladda ner.
                    """)
                    Header(value: "Geometrijakt")
                    Text("""
                    Ladda hem mallen med de geometriska formerna, skriv ut och laminera för hållbarhetens skull. Använd med fördel den utomhus och låt barnen leta efter de olika formerna i naturen och sedan jämföra sina fynd med de utskrivna insekterna eller andra objekt. Diskutera de olika fynden, likheter och olikheter med mer. Benämn de olika formerna med sitt rätta matematiska begrepp, och tänk på att det t ex finns flera olika slags fyrkanter som var och ett har ett eget namn.
                    """)
                    Text("""
                    När barnen har börjat utforska dessa geometriska former, kommer vissa av dem snart att upptäcka att de flesta föremål är uppbyggda av just dessa former. T ex klockor, Lego, Magna-Tiles, bord, fönster, lampor och hus mm.
                    """)
                    Text("""
                    Detta upptäckande av de grundläggande geometriska formerna kan utforskas vidare genom att börja skapa och konstruera i 3D, måla, rita med mera. Notera att formerna i 3D-format har andra namn. Till exempel kan man skapa en kub med sex kvadrater.
                    """)
                    Header(value: "Utforska geometri och matematik utomhus")
                    Text("""
                    Diskutera skillnaderna mellan geometriska former, till exempel vad som skiljer en oval från en cirkel. Om du delar en kvadrat diagonalt på mitten, får du två likadana rätvinkliga trianglar. Men framför allt, leta efter geometriska former genom att gå på Geometrijakt. Du kan till exempel göra en formkikare av två toarullar och leta efter cirklar. Och glöm inte att använda korrekta begrepp när du pratar med barnen. Det de hör dig säga tar de till sig förr eller senare.
                    """)
                    Header(value: "Fantasiinsekter i estetiska lärprocesser")
                    Text("""
                    Låt barnen ta intryck av naturupplevelser, egna erfarenheter och sin omgivning. Vi tänker att man inleder med att ställa frågor till barnen som exempelvis; vad kännetecknar en insekt? Vilka färger kan en insekt ha? Varför har den dessa färger? Vilka egenskaper kan en insekt ha och varför? Varför behövs insekter i naturen?
                    """)
                    Text("""
                    Barnens tankar och frågeställningar blir katalysator för det fortsatta arbetet i att sammanlänka geometriska figurer med ett naturvetenskapligt undersökande. Hur kan vi med fantasi, kreativitet och estetiska verktyg skapa berättelser och gestaltningar av geometriska fantasiinsekter?
                    """)
                    Text("""
                    Låt barnen laborera med färg, återbruksmaterial, tuschpennor för att teckna, måla eller konstruera sin geometriska fantasiinsekt. Använd med fördel spännpapper på rulle som kan rullas ut på golvet. Det ger barnen ordentligt med plats att arbeta på.
                    """)
                    Text("""
                    I samtal med barnen och under den estetiska processens gång ges utrymme för det språkutvecklande arbetet då barnens berättelser om fantasiinsekterna på olika sätt kan dokumenteras i form av förslagsvis en saga. Att samtala kring insekters syfte och funktion öppnar även upp för viktiga och aktuella hållbarhetsfrågor kring tex pollinerare och kretslopp.
                    """)
                    Header(value: "Dra nytta av flera verktyg")
                    Text("""
                    Om man sätter en så kallad bluebotsvans med formen av en pennhållare längst bak på blueboten, så kan man med hjälp av rätt kod programmera blueboten så att den ritar en cirkel. Cirkeln kan förslagsvis vara ett ramverk för en nyckelpiga, eller annan valfri insekt som barnen ger färg och uttryck med hjälp av olika skapandematerial (se bild).
                    """)
                    Text("""
                    Här ges möjlighet ett till lärande inom programmering kopplat till estetik. Barnen får kunskap om och erfarenhet av hur programmering kan användas i konstnärligt syfte, men där fokus ligger på den estetiska processen.
                    """)
                    Text("""
                    I Laiban kan barnen sedan pröva att återskapa en ai-genererad version av sin fantasiinsekt. Eftersom vi inte alltid vet vad Laiban genererar för typ av insekt så blir det extra viktigt att guida barnen genom processen i hur vi tränar den i vad de ska göra, hur viktigt det är med instruktioner innan, och hur viktiga de olika valen blir för att få Laiban att göra som vi vill. Ta gärna hjälp av de samtalsfrågor som finns i slutet denna lärarhandledning. De frågor och tankar som väcks hos barnen i samspel med Laiban behöver få fortsätta ta sig i uttryck i de kreativa processerna.
                    """)
                    Text("""
                    Låt tex barnen bygga vidare på sin insekt med utökade skapandematerial alternativt skapa nya fantasiinsekter med olika egenskaper och utseenden kopplat till barnens tankar.
                    """)
                    HStack {
                        Image("Image1", bundle: .module)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Image("Image2", bundle: .module)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    Header(value: "Användarinstruktioner Laiban")
                    Text("""
                    1. Välj en insekt som du vill skapa
                    2. Välj vilken geometrisk form du vill att den ska ha
                    3. Välj vilken färg du vill att din geometriska insekt ska ha
                    4. Generera!
                    5. Påbörja en kreativ process utifrån barnets AI-genererade insekt
                    """)
                    Header(value: "Frågor att samtala med barnen kring")
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
    }
}

struct InstructionsAdminView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsAdminView()
    }
}
