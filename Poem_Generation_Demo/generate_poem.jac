import from byllm { Model }

glob llm = Model(model_name="gemini/gemini-2.5-pro");

obj Poem {
    has title: str;
    has subject: str;
    has person_for: str;
    has body: str;
}

sem Poem = """
Write a short, heartfelt poem.
Fields:
- title: keep as given
- subject: keep as given
- person_for: keep as given
- body: the poem text (4–8 lines)
- Copyright: "© <current year> Langst"
Rules:
- Return only these fields.
- No URLs, no “provider list”, no explanations.
""";

def generate_poem(subject: str, person_for: str, title: str )-> Poem by llm();

with entry {
    print("💌 Poem Generator");
    let title = input("Enter a title: ");
    let subject = input("Enter the subject of the poem: ");
    let person_for = input("Who is this poem for? ");

    let mypoem = generate_poem(subject, person_for, title);

    print("\n--- Your Poem ---\n");
    print("Title:", mypoem.title);
    print("\n");
    print(mypoem.body);
    print("\n© 2025 Langston");
}