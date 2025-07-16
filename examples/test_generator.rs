use crates_io_og_image::{
    OgImageAuthorData, OgImageCommunityData, OgImageData, OgImageDataPoint, OgImageGenerator,
    OgImageGraphData,
};
use tracing::level_filters::LevelFilter;
use tracing_subscriber::{EnvFilter, fmt};

fn init_tracing() {
    let env_filter = EnvFilter::builder()
        .with_default_directive(LevelFilter::DEBUG.into())
        .from_env_lossy();

    fmt().compact().with_env_filter(env_filter).init();
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    init_tracing();

    println!("Testing OgImageGenerator...");

    let generator = OgImageGenerator::from_environment()?;
    println!("Created generator from environment");

    // Test generating an image
    let data = OgImageData {
        question: "Hello, world",
        author: OgImageAuthorData::new("t1c_dev", "https://avatars.githubusercontent.com/u/141300"),
        community: OgImageCommunityData::new(
            "example",
            "https://avatars.githubusercontent.com/u/141300",
        ),
        outcome: "NONE",
        graph: &[
            OgImageGraphData {
                outcome: "No",
                color: "#D8605A",
                data: &[
                    OgImageDataPoint {
                        time: 1744249342,
                        value: 50,
                    },
                    OgImageDataPoint {
                        time: 1744249396,
                        value: 40,
                    },
                    OgImageDataPoint {
                        time: 1744352237,
                        value: 25,
                    },
                    OgImageDataPoint {
                        time: 1744757651,
                        value: 99,
                    },
                    OgImageDataPoint {
                        time: 1744924914,
                        value: 95,
                    },
                    OgImageDataPoint {
                        time: 1745010415,
                        value: 60,
                    },
                    OgImageDataPoint {
                        time: 1745266299,
                        value: 90,
                    },
                    OgImageDataPoint {
                        time: 1745466299,
                        value: 90,
                    },
                ],
            },
            OgImageGraphData {
                outcome: "Yes",
                color: "#00F29C",
                data: &[
                    OgImageDataPoint {
                        time: 1744249342,
                        value: 50,
                    },
                    OgImageDataPoint {
                        time: 1744249423,
                        value: 60,
                    },
                    OgImageDataPoint {
                        time: 1744924887,
                        value: 5,
                    },
                    OgImageDataPoint {
                        time: 1745010399,
                        value: 40,
                    },
                    OgImageDataPoint {
                        time: 1745010432,
                        value: 50,
                    },
                    OgImageDataPoint {
                        time: 1745010443,
                        value: 50,
                    },
                    OgImageDataPoint {
                        time: 1745266284,
                        value: 10,
                    },
                    OgImageDataPoint {
                        time: 1745466299,
                        value: 10,
                    },
                ],
            },
        ],
    };
    match generator.generate(data).await {
        Ok(temp_file) => {
            let output_path = "test_og_image.png";
            std::fs::copy(temp_file.path(), output_path)?;
            println!("Successfully generated image at: {output_path}");
            println!(
                "Image file size: {} bytes",
                std::fs::metadata(output_path)?.len()
            );
        }
        Err(error) => {
            println!("Failed to generate image: {error}");
            println!("Make sure typst is installed and available in PATH");
        }
    }

    Ok(())
}
