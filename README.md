# <b>Projektplan: Quiz-sida </b>
_Webbutveckling 2_

</br>

## Skisser

</br>

- **Resource**: ‘/’ & ‘/all’
- **Format**: desktop.
- **Kommentar**: ‘/all’ kommer endast skilja sig från ‘/’ på två sätt: titeln som säger “Dina quiz” säger “Alla quiz” istället, och att quizen i listan  i ‘/all’ kommer att ange skapare.
- **Kommentar**: ‘/all’ är endast tillgänglig för admin.

</br>

- **Resource**: ‘/’ & ‘/all’
- **Format**: mobile.

</br>

- **Resource**: ‘/forms’
- **Format**: desktop & mobile.

</br>

- **Resource**: ‘/quiz/:id’
- **Format**: desktop.

</br>

- **Resource**: ‘/quiz/:id’
- **Format**: mobile.

</br>

- **Resource**: ‘/quiz/create’ & ‘/quiz/:id/edit’
- **Format**: desktop.

</br>

- **Resource**: ‘/quiz/create’ & ‘/quiz/:id/edit’
- **Format**: mobile.

</br>

# Projektplan
Jag tänker arbeta med mer eller mindre en sida per vecka, och jag kommer jobba med HTML, CSS och JS parallellt, dvs. jag kommer arbeta på den aspekt av sidan som är mest aktuell. Det är nog också viktigt att nämna att detta front-end-projekt kommer att kombineras med det back-end-projektet jag gör i Webbserverprogrammering.

</br>

### **v10**
Index-sidan.

</br>

### **v11**
Forms-sidan.

</br>

### **v12**
Create- & edit-sidorna.

</br>

### **v13**
Create- & edit-sidorna.

</br>

### **v14**
All-sidan.

</br>

### **v15**
Påsklov.

</br>

### **v16**
Quiz-sidan.

</br>

### **v17**
Quiz-sidan.

</br>

### **v18**
Mobil-versioner.

</br>

### **v19**
Färdigställ.

</br>

# Genomförande

### **v10**
Jag började med att skissa desktop-sidorna.

Sedan började jag på HTML:en och skapade sedan CSS-variabler under body-taggen för de huvudsakliga färger som jag kommer använda samt för tre olika mått som jag kommer utgå från (mha. CSS calc-funktion). Detta gör det lättare att ändra på saker.

Jag har gjort en button-klass som jag kommer använda genom alla sidor. 

Jag har dessutom gjort header och nav, samt hela index-sidan. Jag använder en ul-tagg för att lista ut quizzes från back-end. Jag använder endast flexbox än så länge, ingen grid.

</br>

### **v11**
Sjuk.

</br>

### **v12**
Har gjort både små och stora justeringar på index-sidan. Huvudsakligen så har jag lagt till en knapp i quiz-conteinerna med texten “View description”. Dessa gör att quizets beskrivning öppnas under. Enkelt förklarat så har jag ett element med beskrivningen i som läggs längst ned i conteinern, men med höjden 0 och opacity 0 från början. Sedan använder jag JS för att lägga till klassen ‘open’ på detta elementet vilket ger både höjd och opacity. Jag använder transition attributet för att ge en animation.

Sedan har jag även skapat forms-sidan, och skapat innehållet: två formulär. Dessa ligger i en container med bredden 200vw, alltså dubbelt så brett som fönstret. Jag har en knapp som säger “Byt formulär”. Med JS gör jag att ett tryck på knappen skiftar formulär-containern så att ett nytt formulär visas. Man kan alltså byta mellan login-formuläret och signup-formuläret.

Problem: formulär-containern vägrar lägga formulären i mitten av skärmen.

</br>

### **v13**
Har jobbat på create-sidan. Detta blev komplicerat eftersom jag vill göra det intuitivt för användaren att lägga till och ta bort svar och frågor. Därför använder jag en del eventListeners (eller snarare click-funktioner eftersom jag använder jQuery) och if-metoder inuti dessa. Jag ger attributerna qid (för “question id”) och aid (för “answer id”) till frågorna och svaren. Jag har en select-klass som läggs på den svar eller fråga som användaren klickar på. Detta visas med en vit ram kring elementet. Mha. select-klassen och id-attributerna kan jag göra så att när man klickar på “+Fråga”- eller “+Svar”-knappen så läggs en fråga eller ett svar till på lämpligt ställe. Om man valt en fråga så lägger "+Fråga" till en fråga under den valda och “+Svar” lägger till ett svar längst ned bland svaren kopplade till den valda frågan. Om man valt ett svar så lägger “+Fråga” till en fråga efter den frågan som det valda svaret är kopplat till och “+Svar” lägger till ett svar efter det valda svaret.

Dessutom använder jag jQuery för att kompilera ett JS-objekt av svaren och frågorna och sedan konvertera det till en JSON-hash som jag skickar med formuläret on submit. 

</br>

### **v14**
Har jobbat på edit-sidan. Mycket av det är samma som create-sidan. Det största området som avskiljer är att den information som finns i databasen ska stoppas in när sidan laddar in. Men detta kunde jag göra med hjälp av value-attributet i HTML:en.

Har också jobbat på all-sidan, som är ungefär samma som index-sidan.

</br>

### **v15**
Påsklov.

</br>

### **v16**
Löste problemet med forms-sidan. 

Har börjat på quiz-sidan, där man spelar quizet.

</br>

### **v17**
Är klar med quiz-sidan. Det blev väldigt mycket JS. Jag har en knapp som startar quizet, dvs. den kallar på funktionen “playQuiz” som tar in quiz-datan samt frågan som ska visas. Start-knappen skickar naturligtvis in 0 så att första frågan visas. “playQuiz” anropar på två andra funktioner: först “createQuestion” och sedan “progressBar”. Detta gör att frågan först visas och sedan körs en progress-bar mha. JS setInterval. Då progress-bar:en är färdig så visas frågorna och en timer startar. En eventListener skapas som gör att när användaren klickar på en av frågorna så visas det först om svaret var rätt eller fel, sedan uppdateras poäng-variabeln och tids-variabeln, och sedan kollas det om det finns en till fråga. Om det finns någon mer fråga så anropas “playQuiz” igen med nästa frågas index, annars visas slutskärmen. Det är en krånglig process att förklara i ord, men funktionerna liksom loopar igenom varandra tills den sista frågan är besvarad.

Ett problem som uppstod var att när jag försökte slumpa ordningen som svaren visades så hade jag gjort ett fel så att svar-array:en flyttade element 0 till element -1 och gjorde element 0 till undefined. Och när jag testade arrayen så loggade jag den före slump-funktionen anropades, så jag antog att felet inte hade med den att göra. Nu förstår jag att “var” i JavaScript inte fungerar så. Det var ett sådant där extra retsamt litet misstag.

På denna sida använder jag grid till svaren.

</br>

### **v18**
Har gjort tilläggning av ägare för quiz mer intuitivt i create- och edit-sidorna. Detta har jag gjort med hjälp av AJAX, som man kan använda för att skicka in sökningar och som tar emot resultat.

Har börjat på responsiv design — dvs. mobile-format — mha. “media screen”. 
Använder max-width: 820px.

</br>

### **v19**
Sjuk.

Färdigställde responsiv design och skrev analys.

</br>

# Analys
Jag har gjort en webbsida som är lämplig för syftet, dvs. att skapa och spela quiz. Sidan tillåter inloggning och navigation mellan sidor samt intuitiv skapning, redigering och slängning av quiz. Att spela quiz är också relativt intuitivt. Ett förbättringsområde däremot är att tillåta mer intuitiv delning av quiz, till exempel förmågan att bläddra bland existerande quiz och sökning av quiz. Det enda sättet för tillfället att få tillgång till någon annans quiz är genom att bli tillagd av skaparen. Men det huvudsakliga syftet var inte delning, utan endast skapning av quiz, och det är uppnått. Sidans design är relativt simpel, men tydlig, med lämplig kontrast mellan text och bakgrund. Sidans layout justeras dessutom responsivt för att passa användarens fönster/enhet.
