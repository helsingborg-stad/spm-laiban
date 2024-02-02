//
//  SwiftUIView.swift
//  
//
//  Created by Dan Nilsson on 2024-02-02.
//

import Foundation
import SwiftUI


@available(iOS 17, *)
struct SettingsAdminView: View {
    @ObservedObject var service: ImageGeneratorService
    
    var urlProxy: Binding<String> {
        Binding<String>(get: {
            return service.data.downloadUrl
        }, set: {
            service.data.downloadUrl = $0
            service.save()
        })
    }
    
    var positivePromptProxy: Binding<String> {
        Binding<String>(get: {
            return service.data.positivePrompt
        }, set: {
            service.data.positivePrompt = $0
            service.save()
        })
    }
    
    var negativePromptProxy: Binding<String> {
        Binding<String>(get: {
            return service.data.negativePrompt
        }, set: {
            service.data.negativePrompt = $0
            service.save()
        })
    }
    
    var stepsProxy: Binding<Float> {
        Binding<Float>(get: {
            return Float(service.data.steps)
        }, set: {
            service.data.steps = Int($0)
            service.save()
        })
    }
    
    var scaleProxy: Binding<Float> {
        Binding<Float>(get: {
            return service.data.scale
        }, set: {
            service.data.scale = $0
            service.save()
        })
    }
    
    var sizeProxy: Binding<Float> {
        Binding<Float>(get: {
            return Float(service.data.size)
        }, set: {
            service.data.size = Int($0)
            service.save()
        })
    }
    
    var reduceMemoryProxy: Binding<Bool> {
        Binding<Bool>(get: {
            return service.data.reduceMemory
        }, set: {
            service.data.reduceMemory = $0
            service.save()
        })
    }
    
    var useControlNetProxy: Binding<Bool> {
        Binding<Bool>(get: {
            return service.data.useControlNet
        }, set: {
            service.data.useControlNet = $0
            service.save()
        })
    }
    
    var initOnStartupProxy: Binding<Bool> {
        Binding<Bool>(get: {
            return service.data.initOnStartup
        }, set: {
            service.data.initOnStartup = $0
            service.save()
        })
    }
    
    var body: some View {
        let managerIsBusy = [.Initializing, .Generating].contains(service.manager.status)
        Form {
            if managerIsBusy {
                Section(header: Text("Väntar på att bildgeneratorn ska bli redo...(\(service.manager.statusMessage))")) { }
            }
            
            Section(footer: Text("Att ladda in data vid app-start gör så att man snabbare kan komma igång med att generera bilder, men tar upp mer minne på enheten. Rekommenderat: på om bildgenerering används mycket, annars av.")) {
                Toggle(isOn: initOnStartupProxy) {
                    Text("Ladda in data vid app-start")
                }
            }
            
            Section(header: Text("Modelinställningar"), footer: Text("Dessa inställningar påverkar modelen som används för bildgenerering. Modellen styr i grova drag utseendet på bilderna (t.ex. realistisk eller tecknad) samt kan påverka kvaliteten på subjektet i bilden.")) {
                Section {
                    HStack {
                        Text("Nedladdningslänk till model fil")
                        TextEditor(text: urlProxy)
                    }
                    
                    if #available(iOS 16.0, *) {
                        HStack {
                            Button {
                                UrlModelProvider.cleanModels()
                            } label: {
                                Text("Radera nedladdade modeller").foregroundColor(.red)
                            }
                            
                            Text(UrlModelProvider.getModelCacheSizeString() ?? "")
                        }
                    }
                }
            }
            
            Section(header: Text("Genereringsinställningar"),
                    footer: Text("Promptar används för att beskriva bilden som ska genereras i grova drag. Positiv prompt är det man gärna vill se. Negativ prompt är det man inte vill se. Hur promptarna tolkas beror på den exakta modellen som används (se modellinställningar).")) {
                Section {
                    HStack {
                        Text("Positiv prompt:")
                        TextEditor(text: positivePromptProxy)
                    }
                    HStack {
                        Text("Negativ prompt:")
                        TextEditor(text: negativePromptProxy)
                    }
                }
            }
            
            Section(footer: Text("Antal steg är hur 'djupt' AI:n går in på detalj. Fler steg ger generellt bättre/tydligare bilder men tar längre tid att generera. För många steg kan resultera i att appen kraschar. Rekommenderat: 10-30.")) {
                HStack {
                    Text("Steg")
                    Slider(value: stepsProxy, in: 2...50, step: 1)
                    Text("\(service.data.steps)")
                }
            }
            
            Section(footer: Text("Skalan är hur noggrant AI:n följer prompten. För låg eller hög skala tenderar till att generera godtyckligt brus. Rekommenderat: 5-10.")) {
                HStack {
                    Text("Konfigurationsskala")
                    Slider(value: scaleProxy, in: 1...20, step: 0.5)
                    Text(String(format: "%.1f", service.data.scale))
                }
            }
            
            Section(footer: Text("Storleken på bilden som genereras. Högre värde ger skarpare bild men tar exponentiellt längre tid att generera och för stor bild kan resultera i att appen kraschar. Rekommenderat: 512.")) {
                HStack {
                    Text("Storlek")
                    Slider(value: sizeProxy, in: 256...1024, step: 256)
                    Text("\(service.data.size)x\(service.data.size)")
                }
            }
            
            Section(footer: Text("Att reducera minnesanvändningen kan förhindra att appen kraschar, men gör att bildgenereringen tar längre tid. Rekommenderat: på.")) {
                Toggle(isOn: reduceMemoryProxy) {
                    Text("Reducera minnesanvändning")
                }
            }
            
            Section(footer: Text("ControlNet används för att i detalj finjustera formen som genereras (t.ex. att vara en fyrkant eller cirkel) men kräver att modellen som används stödjer det. Rekommenderat: beroende på modell.")) {
                Toggle(isOn: useControlNetProxy) {
                    Text("Använd ControlNet")
                }
            }
        }.disabled(managerIsBusy)
    }
}

@available(iOS 17, *)
struct SettingsAdminView_Previews: PreviewProvider {
    static var service = ImageGeneratorService()
    static var previews: some View {
        SettingsAdminView(service: service)
    }
}
