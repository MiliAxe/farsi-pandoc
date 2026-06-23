# Farsi Pandoc

During my studies at university, I have came across multiple scenarios
where I needed to write clean documents for various subjects and needs.
Writing `LaTeX` code was a little bit cumbersome for daily needs, and I
couldn't really afford to write `TeX` files every single time for assignments.

Because of this, [Pandoc](https://pandoc.org/) has been an awesome tool so far.
I would just write markdown (`.md`) files and this great tool would
convert them to a clean `PDF` file for me.

Pandoc allows you to write templates in which you would easily structure
your assignments, projects, reports and such with a clean output. There
is one issue here though, Pandoc doesn't really like Farsi being
RTL, and you have to handle it yourself to get a clean output.

This means writing a `LaTeX` template that would use the `xepersian` package
to handle Farsi typesetting. This repository includes my templates and tools
I have accumulated over time to make the experience of writing
Farsi documents with pandoc easier.

## Usage

I have included several templates that I have used in [templates](templates/).
It includes templates for writing assignments, projects and so on. It might
also include other experimental templates that I derived from the original
ones over time for different purposes.
