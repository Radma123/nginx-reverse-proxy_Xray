import ContentCard from "../components/ContentCard"
import { useState, useEffect } from "react";
import '../css/Home.css'
import { getPopularContent, searchContent } from "../services/api";

function Home() {
    const [searchQuery, setSearchQuery] = useState("");
    const [content_objects, setContentObjects] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    
    useEffect(() => {
        const fetchPopularContent = async () => {
            console.log("fetchPopularContent");
            try {
                const data = await getPopularContent();
                setContentObjects(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };
        fetchPopularContent();
    }, []);

    //     {id: 2,title: "Another Title", release_year: "2022", poster:"https://cdn.pixabay.com/photo/2018/01/14/23/12/nature-3082832_640.jpg"},
    //     {id: 3,title: "Sample Content", release_year: "2021", poster:"https://microsoft.design/wp-content/uploads/2025/10/wip11-crop-light.png"},
    // ];


    const handleSearch = async (e) => {
        e.preventDefault();
        
        if (!searchQuery.trim()) {
            return;
        }
        if (loading) return;

        setLoading(true);
        try {
            const searchResults = await searchContent(searchQuery);
            setContentObjects(searchResults);
            setError(null);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="Home">
            {/* search form */}
            <form className="search-form" onSubmit={handleSearch}>
                <input
                 type="text" 
                 placeholder="Search..." 
                 className="search-input" 
                 value={searchQuery} 
                 onChange={(e) => setSearchQuery(e.target.value)} 
                />
                <button type="submit" className="search-button">Search</button>
            </form>

            {/* content grid */}
            
            {loading ? (
                <p>Loading...</p>
            ) : (
            <div className="content-grid">
                {content_objects.map((content) => (
                    content.title.toLowerCase().startsWith(searchQuery.toLowerCase()) &&
                    <ContentCard key={content.id} content_obj={content} />
                ))}
            </div>
            )}

            {error && <p className="error-message">Error: {error}</p>}
        </div>
    )
}

export default Home;