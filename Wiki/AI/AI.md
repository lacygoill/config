# How to get an AI-generated
## code script from the command-line?

    $ pipx install git+https://github.com/jayhack/llm.sh
    $ llm 'your prompt'

Example 1:

    $ llm 'create a csv with four japanese-sounding names in it'
```bash
 #!/bin/bash -

 # Create a new file called 'result.csv' and add the header
touch results.csv
echo "name" > results.csv

 # Add four japanese-sounding names to the csv
echo "Hiroshi" >> results.csv
echo "Kazuya" >> results.csv
echo "Yukiko" >> results.csv
echo "Takashi" >> results.csv
```
Example 2:

    $ llm 'download a test image to this directory'
```bash
 #!/bin/bash -

 # Download a test image to the current directory
wget https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/Test_image.jpg/220px-Test_image.jpg
```
Example 3:

    $ llm 'make a python env with numpy'
```bash
 #!/bin/bash -

 # create a new virtual environment
python3 -m venv my_env

 # activate the virtual environment
source my_env/bin/activate

 # install numpy
python3 -m pip install --upgrade numpy
```
## image?

<https://stablediffusionweb.com/>

## transcript from a video?

<https://github.com/openai/whisper>

##
# How to use something like ChatGPT without giving a phone number?

Try this site: <https://freegpt.one/>

---

Alternative: <https://beta.character.ai/>

After some prompts, it requires an inscription.  Use a throwaway email:
<https://www.emailondeck.com/>

No phone number required.

---

Another possible alternative: <https://poe.com/chatgpt>
This one does require an email.
Not sure whether a throwaway one works.

##
# To read

<https://learnprompting.org/docs/intro>

# To watch

I Don't Trust Websites! - The Everything API with ChatGPT
<https://www.youtube.com/watch?v=M2uH6HnodlM>

Attacking LLM - Prompt Injection
<https://www.youtube.com/watch?v=Sv5OLj2nVAQ>

Can AI Create a Minecraft Hack?
<https://www.youtube.com/watch?v=ukKfAV4Ap6o>

---

Although, not sure hacking is a good angle to approach AI...
Maybe if you're concerned with security?
Or if you want to get more inspiration about original tool(s) to build around AI?

##
# To choose
## OpenAI vs LLaMa

I would prefer we use LLaMa because it can run locally on a Linux machine, while
OpenAI requires you to be connected to the internet and to have an API key.
And since it runs locally, LLaMa is probably more configurable.

Whatever you use,  strive for something which consumes little  power.  You could
temporarily rent a  server to train a  model, then run the model  on a low-power
system (e.g.  a raspberry pi).   That should  be possible according  to Geoffrey
Hinton:

   > So I think there's going to be a phase when we train on digital computers.
   > But once something is trained, we run it on very low-power systems.

Source: <https://www.youtube.com/watch?v=qpoRO378qRY&t=1271s>

---

BTW, regarding this:

   > In order to download the checkpoints and tokenizer, fill this google form

Don't worry.  You shouldn't need to fill anything.
Try to download the files via this magnet link:

    magnet:?xt=urn:btih:ZXXDAUWYLRUXXBHUYEMS6Q5CE5WA3LVA&dn=LLaMA

Source: <https://github.com/facebookresearch/llama/pull/73/files>

But beware, the file  is huge; make sure you have  enough storage space *before*
starting the download.   Last time we tried, it caused  unexpected errors on our
system because we don't have enough space ATM.

## LangChain vs LlamaIndex

Which one should we use?

- <https://python.langchain.com/en/latest/index.html>
- <https://gpt-index.readthedocs.io/en/latest/index.html>

It seems  that LangChain is more  popular on GitHub, but  its documentation only
mentions OpenAI, not LLaMa.

I *think* LangChain can support LLaMa:
<https://github.com/hwchase17/langchain/pull/2242>

And I *think* LangChain is more powerful.
But maybe both are useful in their own right?
