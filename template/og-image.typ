// =============================================================================
// Inertia OG image template
// Based on the crates.io OG image template:
// https://github.com/rust-lang/crates_io_og_image
// =============================================================================
// This template generates Open Graph images for crates.io crate.

// =============================================================================
// COLOR PALETTE
// =============================================================================

#let colors = (
    bg: gradient.linear(rgb(0, 97, 63), rgb(0, 51, 33), rgb(0, 25, 17), rgb(0, 25, 17), rgb(0, 25, 17),  rgb(0, 97, 63), angle: 45deg),
    logo-overlay: oklch(43.5%, 0.1, 161deg, 30%),
    header-text: oklch(100%, 0, 0deg),
    primary: rgb(41, 255, 180),
    text: rgb(229, 255, 246),
    text-light: rgb(204, 255, 237),
    avatar-bg: oklch(100%, 0, 0deg),
    avatar-border: oklch(87%, 0.01, 98deg),
)

// =============================================================================
// LAYOUT CONSTANTS
// =============================================================================

#let header-height = 80pt

// =============================================================================
// TEXT TRUNCATION UTILITIES
// =============================================================================
// These functions handle text overflow by adding ellipsis when content
// exceeds specified dimensions

// Truncates text to fit within a maximum height
// @param text: The text content to truncate
// @param maxHeight: Maximum height constraint (optional, defaults to single line height)
#let truncate_to_height(text, maxHeight: none) = {
    layout(size => {
        let text = text

        let maxHeight = if maxHeight != none {
            maxHeight
        } else {
            measure(text).height
        }

        if measure(width: size.width, text).height <= maxHeight {
            return text
        } else {
            while measure(width: size.width, text + "…").height > maxHeight {
                // Use character-based slicing instead of byte-based to handle Unicode correctly
                let chars = text.clusters()
                if chars.len() == 0 {
                    break
                }
                text = chars.slice(0, chars.len() - 1).join().trim()
            }
            return text + "…"
        }
    })
}

// Truncates text to fit within a maximum width
// @param text: The text content to truncate
// @param maxWidth: Maximum width constraint (optional, defaults to container width)
#let truncate_to_width(text, maxWidth: none) = {
    layout(size => {
        let text = text

        let maxWidth = if maxWidth != none {
            maxWidth
        } else {
            size.width
        }

        if measure(text).width <= maxWidth {
            return text
        } else {
            while measure(text + "…").width > maxWidth {
                // Use character-based slicing instead of byte-based to handle Unicode correctly
                let chars = text.clusters()
                if chars.len() == 0 {
                    break
                }
                text = chars.slice(0, chars.len() - 1).join().trim()
            }
            return text + "…"
        }
    })
}

// =============================================================================
// IMAGE UTILITIES
// =============================================================================
// Functions for loading and processing images

// Loads an SVG icon and replaces currentColor with the specified color
// @param icon-name: The name of the SVG file (without .svg extension)
// @param color: The color to replace currentColor with
// @param width: The width of the image (default: auto)
// @param height: The height of the image (default: auto)
#let colored-image(path, color, width: auto, height: auto) = {
    let svg = read(path).replace("currentColor", color.to-hex())
    image(bytes(svg), width: width, height: height)
}

// =============================================================================
// AVATAR RENDERING
// =============================================================================
// Functions for rendering circular avatar images

// Renders a circular avatar image with border
// @param avatar-path: Path to the avatar image file
// @param size: Size of the avatar (default: 1em)
#let render-avatar(avatar-path, size: 1em, radius: 50%) = {
    box(clip: true, fill: colors.avatar-bg, stroke: 0.5pt + colors.avatar-border,
        radius: radius, inset: 1pt,
        box(clip: true, radius: 50%, image(avatar-path, width: size))
    )
}

// =============================================================================
// AUTHOR HANDLING
// =============================================================================
// Complex logic for displaying multiple authors with proper grammar

// Renders an author with optional avatar and name
#let render-author(author) = {
    if author.avatar != none {
        h(0.2em)
        box(baseline: 30%, [#render-avatar(author.avatar, size: 1.25em)])
        h(0.2em)
    }
    [*#author.name*]
}

// Renders a community with optional avatar and name
#let render-community(community) = {
    if community.avatar != none {
        h(0.2em)
        box(baseline: 30%, [#render-avatar(community.avatar, size: 1.25em, radius: 25%)])
        h(0.2em)
    }
    [*i\/#community.handle*]
}

#let render-author-community(author, community) = {
    return [By #render-author(author) in #render-community(community)]
}

// =============================================================================
// VISUAL COMPONENTS
// =============================================================================
// Reusable components for consistent styling

#let render-header = {
    rect(width: 100%, height: header-height, stroke: none, {
        place(left + horizon, dx: 30pt, {
            box(baseline: 30%, image("assets/og-template.svg", width: 180pt))
            // h(10pt)
            // text(size: 22pt, fill: colors.header-text, weight: "semibold")[inetia.social]
        })
    })
}

// Renders a tag/keyword with consistent styling
#let render-tag(content) = {
    set text(fill: colors.tag-text)
    box(fill: colors.tag-bg, radius: .15em, inset: (x: .4em, y: .25em),
        content
    )
}

// Renders a metadata item with icon, title, and content
#let render-metadata(content, icon-name) = {
    let icon-path = "assets/" + icon-name + ".svg"

    box(inset: (right: 20pt),
        grid(columns: (auto, auto), rows: (auto, auto), column-gutter: 0.6em, row-gutter: .5em, align: horizon,
            colored-image(icon-path, colors.text-light, height: 16pt),
            text([*#content*], size: 16pt, fill: colors.text)
        )
    )
}

// =============================================================================
// DATA LOADING
// =============================================================================
// Load data from sys.inputs

// #let data = json(bytes(sys.inputs.data))
#let data = json("data.json")
// #let avatar_map = json(bytes(sys.inputs.at("avatar_map", default: "{}")))

// =============================================================================
// MAIN DOCUMENT
// =============================================================================

#set page(width: 600pt, height: 315pt, margin: 0pt, fill: colors.bg)
#set text(font: "IBM Plex Sans", fill: colors.text)

#render-header

// Inertia logo overlay (30% opacity watermark)
#place(bottom + right, dx: 150pt, dy: 90pt,
    colored-image("assets/inertia.svg", colors.logo-overlay, width: 420pt)
)

// Main content area
#place(
    left + top,
    dy: 40pt,
    block(height: 100% - header-height, inset: 35pt, clip: false, {
        // Question
        block(text(size: 24.9pt, weight: "semibold", fill: colors.primary, data.question))

        // Tags
        // if data.at("tags", default: ()).len() > 0 {
        //     block(
        //         for (i, tag) in data.tags.enumerate() {
        //             if i > 0 {
        //                 h(3pt)
        //             }
        //             render-tag(text(size: 8pt, weight: "medium", "#" + tag))
        //         }
        //     )
        // }

        // Rules
        if data.at("rules", default: none) != none {
            block(
              text(size: 18pt, weight: "regular", truncate_to_height(data.rules, maxHeight: 80pt)),
              above: 20pt,
            )
        }

        // Author/community
        if data.at("author", default: ()).len() > 0 {
            set text(size: 15pt, fill: colors.text-light)
            let author-with-avatar = {
                let avatar = none
                if data.author.avatar != none {
                        avatar = "assets/" + data.author.avatar
                }
                (name: data.author.name, avatar: avatar)
            }
            let community-with-avatar = {
                let avatar = none
                if data.community.avatar != none {
                    avatar = "assets/" + data.community.avatar
                }
                (handle: data.community.handle, avatar: avatar)
            }
            block(render-author-community(author-with-avatar, community-with-avatar), below: 24pt)
        }

        // Metadata
        stack(dir: ltr, {
          render-metadata(data.likes, "likes")
          render-metadata(text([\$#calc.round(data.volume / 100, digits: 2)]), "volume")
        })
    })
)
